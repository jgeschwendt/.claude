#!/usr/bin/env bun
// @ts-check

// Claude Code statusline. Each render tick, the CLI pipes one StatusInput JSON payload to stdin
// and prints whatever comes back on stdout as the statusline:
//
//   Fable 5 (fast · low) ██████████▎░░░░░░░░░░░ 52% ≈46m · $1.20 · 5h 31%† ↻ 10:50pm
//   ├─────┘ ├──────────┘ ├────────────────────────┘ ├────┘ ├──────────────────────┘
//   │ model │ mode flags │ context usage            │ cost │ 5h rate limit
//
// Every segment is conditional — absent data leaves no residue:
//   · Mode flags (dim): only when non-default — fast mode on, or effort ≠ high.
//   · Bar + %: total_input_tokens against the AUTO-COMPACT THRESHOLD, not the raw context
//     window — see "Auto-compact threshold" below for how that's resolved. ⅛-block cells;
//     tone shifts green → yellow (50) → orange (75) → red (90) on both bar and digits.
//   · ≈ETA: projected time until auto-compact from recent token velocity — see "Burn rate"
//     below. Appears past 50% usage when a ≥60s trend exists and the projection is <6h.
//   · $cost (dim): session spend so far (cost.total_cost_usd), shown once it rounds to ≥ $0.01.
//   · 5h limit: rate-limit usage (own tone), † when requests exceed 200k tokens (the 2×
//     long-context pricing/rate-limit tier), ↻ reset as local wall-clock time.
//
// Layout: stdout is a pipe, so the real PTY width comes from walking parent PIDs to the shell
// that owns the tty (`columns`). Head/tail are measured as plain strings and only then styled —
// ANSI escapes never count toward width. The bar absorbs whatever columns remain.
//
// Debugging: each tick's payload is dumped to statusline.js.log (last tick wins); a thrown
// error lands there too and the line simply goes blank for that tick.

import { execSync } from "node:child_process";
import { readFileSync, writeFileSync } from "node:fs";
import { writeFile } from "node:fs/promises";
import { homedir, tmpdir } from "node:os";
import { json } from "node:stream/consumers";

/**
 * @typedef {{
 *   context_window?: {
 *     context_window_size?: number;
 *     total_input_tokens?: number;
 *     used_percentage?: number;
 *   };
 *   cost?: { total_cost_usd?: number };
 *   effort?: { level?: string };
 *   exceeds_200k_tokens?: boolean;
 *   fast_mode?: boolean;
 *   model: { display_name: string; id?: string };
 *   rate_limits?: { five_hour?: { resets_at?: number; used_percentage?: number } };
 *   session_id?: string;
 *   workspace?: { project_dir?: string };
 * }} StatusInput
 */

// ── Auto-compact threshold ────────────────────────────────────────────────────────────────────
// Claude Code auto-compacts when total_input_tokens crosses:
//   autoWindow − min(maxOutputTokens, 20_000) − 13_000   (output reserve + compaction reserve)
// so "% until auto-compact" must use that threshold — NOT context_window_size, and NOT a
// hardcoded window (the old 500k guess was ~2× off on models whose auto window is the full 1M).
// The payload exposes neither the auto window nor the threshold, so mirror the CLI's resolution
// precedence (v2.1.198, fn `G3`) from its observable inputs. Every branch is exact except a
// statsig experiment (currently scoped to claude-opus-4-8, unreadable externally) — if the bar
// drifts from the app on that model only, that's why.

const clamp = (/** @type {number} */ v, /** @type {number} */ lo, /** @type {number} */ hi) =>
  Math.min(hi, Math.max(lo, v));

const readJSON = (/** @type {string} */ path) => {
  try {
    return JSON.parse(readFileSync(path, "utf8"));
  } catch {
    return null;
  }
};

// The CLI keys its window tables by base model id — strip Bedrock/Vertex region + vendor
// prefixes and version/date suffixes ("us.anthropic.claude-sonnet-5-20250929-v1:0" →
// "claude-sonnet-5").
const baseModelId = (/** @type {string} */ id) =>
  id
    .toLowerCase()
    .replace(/^(apac|eu|global|us)\./, "")
    .replace(/^anthropic\./, "")
    .replace(/-v\d+(:\d+)?$/, "")
    .replace(/[@-]\d{8}$/, "")
    .replace(/\[1m\]$/, "");

// Window table values are `number` or `{surfaces?: {<CLAUDE_CODE_ENTRYPOINT>: entry}, default?}`.
const surfaceValue = (/** @type {unknown} */ value) => {
  if (typeof value === "number") return value;
  if (typeof value !== "object" || value === null || Array.isArray(value)) return undefined;
  const v = /** @type {Record<string, any>} */ (value);
  const entry = v.surfaces?.[process.env.CLAUDE_CODE_ENTRYPOINT ?? ""] ?? v;
  if (typeof entry === "number") return entry;
  return typeof entry.default === "number" ? entry.default : undefined;
};

// The CLI accepts configured windows only within [100k, 1M].
const validWindow = (/** @type {unknown} */ value) =>
  typeof value === "number" && Number.isInteger(value) && value >= 100_000 && value <= 1_000_000
    ? value
    : undefined;

// Per-model defaults baked into the CLI binary (`gfa` / `rTp` in v2.1.198).
const DEFAULT_WINDOWS = /** @type {Record<string, unknown>} */ ({
  "claude-sonnet-5": {
    default: 967_000,
    surfaces: { "local-agent": 500_000, remote_cowork: 500_000 },
  },
});
const LEGACY_200K_MODELS = new Set(["claude-opus-4-6", "claude-sonnet-4-6"]);

/**
 * Resolve the auto-compact window for `model`, mirroring the CLI's precedence chain.
 * @param {string} model base model id
 * @param {number} windowSize context_window_size from the payload (the hard cap)
 * @param {string | undefined} projectDir
 * @param {any} globalState parsed ~/.claude.json
 */
const autoCompactWindow = (model, windowSize, projectDir, globalState) => {
  // 1. Env override, inherited from the CLI process; clamped to [100k, 1M].
  const env = Number(process.env.CLAUDE_CODE_AUTO_COMPACT_WINDOW);
  if (Number.isFinite(env) && env > 0) return clamp(Math.round(env), 100_000, 1_000_000);

  // 2. `autoCompactWindow` in settings (written by /autocompact); highest-precedence file wins.
  for (const path of [
    "/Library/Application Support/ClaudeCode/managed-settings.json",
    ...(projectDir
      ? [`${projectDir}/.claude/settings.local.json`, `${projectDir}/.claude/settings.json`]
      : []),
    `${homedir()}/.claude/settings.json`,
  ]) {
    const window = validWindow(readJSON(path)?.autoCompactWindow);
    if (window) return window;
  }

  // 3. Server-pushed per-model windows cached in ~/.claude.json (clientdata `rowan_thicket`,
  //    then the bootstrap `auto_compact_windows` → `autoCompactWindowsCache`). Null for this
  //    account today, but this is where new-model windows land without a CLI update.
  const slots = Object.values(globalState.clientDataCacheSlots ?? {}).sort(
    (a, b) => /** @type {any} */ (b?.at ?? 0) - /** @type {any} */ (a?.at ?? 0),
  );
  for (const data of [
    ...slots.map((s) => /** @type {any} */ (s)?.data),
    globalState.clientDataCache,
  ]) {
    const window = validWindow(surfaceValue(data?.rowan_thicket?.[model]));
    if (window) return window;
  }
  const cache = globalState.autoCompactWindowsCache ?? {};
  const cached = validWindow(surfaceValue(cache[model]));
  if (cached) return cached;

  // (The unobservable statsig experiment slots in here; claude-opus-4-8 only as of v2.1.198.)

  // 4. Baked-in model defaults. A model key present-but-invalid in the bootstrap cache
  //    suppresses the static default (`replacesDefault` in the CLI).
  if (windowSize < 1_000_000 && LEGACY_200K_MODELS.has(model)) return 200_000;
  if (!(model in cache)) {
    const fallback = validWindow(surfaceValue(DEFAULT_WINDOWS[model]));
    if (fallback) return fallback;
  }

  // 5. No override anywhere → the full context window is the auto window (source "auto").
  return windowSize;
};

/**
 * Tokens at which auto-compact fires: window − output reserve − 13k compaction reserve.
 * @param {StatusInput} data
 */
const autoCompactThreshold = (data) => {
  const windowSize = data.context_window?.context_window_size || 200_000;
  const globalState = readJSON(`${homedir()}/.claude.json`) ?? {};

  // Auto-compact off (env kill switches or `claude config set autoCompactEnabled false`) → the
  // app shows usage against the full window instead.
  const off = (/** @type {string | undefined} */ v) => v === "1" || v === "true";
  if (
    off(process.env.DISABLE_AUTO_COMPACT) ||
    off(process.env.DISABLE_COMPACT) ||
    globalState.autoCompactEnabled === false
  )
    return windowSize;

  const window = Math.min(
    windowSize,
    autoCompactWindow(
      baseModelId(data.model.id ?? ""),
      windowSize,
      data.workspace?.project_dir,
      globalState,
    ),
  );
  const maxOut = Number(process.env.CLAUDE_CODE_MAX_OUTPUT_TOKENS);
  const outputReserve = Math.min(Number.isFinite(maxOut) && maxOut > 0 ? maxOut : 20_000, 20_000);
  return Math.max(1, window - outputReserve - 13_000);
};

/** Unix timestamp → local wall-clock "10:50pm". */
const clock = (/** @type {number} */ epoch) => {
  const d = new Date(epoch * 1000);
  const h = d.getHours() % 12 || 12;
  return `${h}:${String(d.getMinutes()).padStart(2, "0")}${d.getHours() < 12 ? "am" : "pm"}`;
};

/** Seconds → compact duration ("2h13m", "40m"). */
const dur = (/** @type {number} */ seconds) => {
  const h = Math.floor(seconds / 3600);
  return h
    ? `${h}h${Math.floor((seconds % 3600) / 60)}m`
    : `${Math.max(1, Math.round(seconds / 60))}m`;
};

// ── Burn rate ─────────────────────────────────────────────────────────────────────────────────
// Each tick is a fresh process, so token velocity needs cross-tick state: a rolling sample file
// per session in tmpdir (the OS cleans it up; no pruning logic). Samples land at most every 15s,
// 40 retained ≈ a 10-minute window — long enough to smooth tool-call bursts into a usable rate.
/**
 * @param {string | undefined} sessionId
 * @param {number} tokens current total_input_tokens
 * @param {number} threshold tokens at which auto-compact fires
 * @returns {string} "≈40m" once a trend exists, else ""
 */
const etaToCompact = (sessionId, tokens, threshold) => {
  if (!sessionId || !tokens) return "";
  const path = `${tmpdir()}/claude-statusline-${sessionId}.json`;
  const raw = readJSON(path)?.samples;
  let samples = Array.isArray(raw)
    ? raw.filter((s) => typeof s?.at === "number" && typeof s?.tokens === "number")
    : [];
  const now = Date.now();
  // A token drop means /compact or /clear rewound the context — the old trend describes nothing.
  if (samples.length && tokens < samples[samples.length - 1].tokens) samples = [];
  if (!samples.length || now - samples[samples.length - 1].at >= 15_000)
    samples = [...samples.slice(-39), { at: now, tokens }];
  try {
    writeFileSync(path, JSON.stringify({ samples }));
  } catch {}
  const span = (samples[samples.length - 1].at - samples[0].at) / 1000;
  if (span < 60) return "";
  const rate = (samples[samples.length - 1].tokens - samples[0].tokens) / span;
  if (rate <= 0) return "";
  const eta = (threshold - tokens) / rate;
  // An idle session's rate decays toward 0 and the ETA toward nonsense — hide beyond 6h.
  return eta < 6 * 3600 ? `≈${dur(eta)}` : "";
};

const sh = (/** @type {string} */ cmd) => execSync(cmd, { encoding: "utf8" }).trim();

/**
 * Columns of the controlling PTY. Claude Code pipes our stdout, so `process.stdout.columns` is undefined — walk up to
 * the shell that owns the real tty and ask `stty`, mirroring ccstatusline.
 */
const columns = (/** @type {number} */ fallback = 80) => {
  const flag = process.platform === "darwin" ? "-f" : "-F";
  try {
    for (let pid = process.pid, i = 0; pid > 1 && i < 8; i++) {
      const tty = sh(`ps -o tty= -p ${pid}`);
      if (tty && tty !== "??")
        return Number(sh(`stty ${flag} /dev/${tty} size`).split(" ")[1]) || fallback;
      pid = Number(sh(`ps -o ppid= -p ${pid}`));
    }
  } catch {}
  return fallback;
};

const log = (/** @type {string} */ message) =>
  writeFile(`${import.meta.filename}.log`, `[${new Date().toISOString()}] ${message}\n`);

// ── Rendering ─────────────────────────────────────────────────────────────────────────────────
const BOLD = "\x1b[1m";
const DIM = "\x1b[2m";
const RESET = "\x1b[0m";
const fg = (/** @type {number} */ n) => `\x1b[38;5;${n}m`;

// Muted green → yellow → orange → red as usage climbs (256-color, calm at rest, loud near compact).
const tone = (/** @type {number} */ p) => fg(p >= 90 ? 203 : p >= 75 ? 208 : p >= 50 ? 179 : 108);

// ⅛-block resolution ("██▋░░░") — the partial cell makes slow growth visible between whole cells.
const bar = (/** @type {number} */ p, /** @type {number} */ width) => {
  const eighths = Math.round((p / 100) * width * 8);
  const filled = "█".repeat(Math.floor(eighths / 8)) + ("▏▎▍▌▋▊▉"[(eighths % 8) - 1] ?? "");
  return tone(p) + filled + fg(238) + "░".repeat(Math.max(0, width - filled.length)) + RESET;
};

try {
  const data = /** @type {StatusInput} */ (await json(process.stdin));

  const model = data.model.display_name;
  // total_input_tokens is the app's own numerator (input + cache_read + cache_creation).
  // Missing early in session / after /compact → 0.
  const tokens = data.context_window?.total_input_tokens || 0;
  const threshold = autoCompactThreshold(data);
  const pct = clamp(Math.round((tokens / threshold) * 100), 0, 100);
  // Record velocity every tick, but only surface the ETA once the bar is half full.
  const trend = etaToCompact(data.session_id, tokens, threshold);
  const eta = pct >= 50 ? trend : "";
  // Session spend so far (input + output priced together by the app); hidden until it rounds to a cent.
  const cost = data.cost?.total_cost_usd || 0;
  const usd = cost >= 0.005 ? `$${cost.toFixed(2)}` : "";
  const five = data.rate_limits?.five_hour;
  const fivePct = Math.floor(five?.used_percentage || 0);
  // `exceeds_200k_tokens` flips when requests cross into the 2× long-context pricing tier —
  // the dagger explains sudden rate-limit burn.
  const tier = data.exceeds_200k_tokens ? "†" : "";

  // Non-default mode markers next to the model — silent when running plain high-effort.
  const effort = data.effort?.level;
  const flags = [
    ...(data.fast_mode ? ["fast"] : []),
    ...(effort && effort !== "high" ? [effort] : []),
  ].join(" · ");

  // Plain (unstyled) head/tail measure the layout — ANSI escapes have zero printed width, so
  // sizing must run on the bare strings, styling on the assembled output.
  const head = `${model}${flags ? ` (${flags})` : ""} `;
  const tail =
    ` ${pct}%` +
    (eta ? ` ${eta}` : "") +
    (usd ? ` · ${usd}` : "") +
    (five ? ` · 5h ${fivePct}%${tier}` : "") +
    (five?.resets_at ? ` ↻ ${clock(five.resets_at)}` : "");
  // Claude Code indents the statusline ~2 cols and keeps a right margin, so the printable region is narrower than the PTY width
  // reserve MARGIN or it clips with "…".
  const MARGIN = 4;
  const width = Math.max(0, columns() - MARGIN - head.length - tail.length);

  console.log(
    BOLD +
      model +
      RESET +
      (flags ? ` ${DIM}(${flags})${RESET}` : "") +
      " " +
      bar(pct, width) +
      tone(pct) +
      ` ${pct}%` +
      RESET +
      (eta ? `${DIM} ${eta}${RESET}` : "") +
      (usd ? `${DIM} · ${usd}${RESET}` : "") +
      (five
        ? `${DIM} · 5h ${RESET}${tone(fivePct)}${fivePct}%${RESET}${tier ? `${DIM}†${RESET}` : ""}`
        : "") +
      (five?.resets_at ? `${DIM} ↻ ${clock(five.resets_at)}${RESET}` : ""),
  );

  await log(JSON.stringify(data, undefined, 2));
} catch (error) {
  if (error instanceof Error) {
    await log(`${error.name}: ${error.message}\n${error.stack}`);
  } else {
    await log(`Error: ${String(error)}`);
  }
}
