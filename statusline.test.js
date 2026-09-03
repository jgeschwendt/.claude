// @ts-check

import { afterEach, expect, test } from "bun:test";

const TMP = (Bun.env.TMPDIR ?? "/tmp").replace(/\/$/, "");

// Unknown model + a 200k window resolves to the "auto" branch of autoCompactWindow, so
// autoCompactThreshold is 200_000 − 20_000 output reserve − 13_000 compaction reserve.
const THRESHOLD = 167_000;

/** @type {string[]} */
const dirs = [];

/** Fresh temp dir holding a copy of the statusline, so its `<script>.log` lands inside the dir. */
const setup = async () => {
  const dir = `${TMP}/claude-test-${crypto.randomUUID()}`;
  dirs.push(dir);
  await Bun.write(`${dir}/statusline.js`, Bun.file(`${import.meta.dir}/statusline.js`));
  process.getBuiltinModule("fs").mkdirSync(`${dir}/home`, { recursive: true });
  return dir;
};

/** Base payload: unknown model, half-full-ish 200k window, no cost or rate limits. */
const payload = (/** @type {Record<string, unknown>} */ extra = {}) => ({
  context_window: { context_window_size: 200_000, total_input_tokens: 50_000 },
  model: { display_name: "Fable 5.1", id: "claude-fable-5-1" },
  session_id: "s1",
  ...extra,
});

/**
 * Run the copied statusline with HOME pointed at an empty dir (no settings, no ~/.claude.json)
 * and every auto-compact/entrypoint env var cleared, so only the payload drives the render.
 */
const run = (
  /** @type {string} */ dir,
  /** @type {unknown} */ input,
  /** @type {Record<string, string>} */ extraEnv = {},
) => {
  /** @type {Record<string, string | undefined>} */
  const env = { ...Bun.env, HOME: `${dir}/home`, TMPDIR: dir, ...extraEnv };
  for (const key of [
    "CLAUDE_CODE_AUTO_COMPACT_WINDOW",
    "CLAUDE_CODE_ENTRYPOINT",
    "CLAUDE_CODE_MAX_OUTPUT_TOKENS",
    "DISABLE_AUTO_COMPACT",
    "DISABLE_COMPACT",
  ])
    if (!(key in extraEnv)) delete env[key];
  const { exitCode, stdout } = Bun.spawnSync(["bun", `${dir}/statusline.js`], {
    cwd: dir,
    env,
    stderr: "pipe",
    stdin: new TextEncoder().encode(typeof input === "string" ? input : JSON.stringify(input)),
    stdout: "pipe",
  });
  // ANSI escapes carry no printed width — strip them before asserting on text.
  return { exitCode, out: stdout.toString().replace(/\x1b\[[0-9;]*m/g, "") };
};

const pct = (/** @type {string} */ out) => Number(out.match(/ (\d{1,3})%/)?.[1]);

afterEach(() => {
  const { rmSync } = process.getBuiltinModule("fs");
  for (const dir of dirs.splice(0)) rmSync(dir, { force: true, recursive: true });
});

test("hides the cost segment below a cent", async () => {
  const dir = await setup();

  const { exitCode, out } = run(dir, payload({ cost: { total_cost_usd: 0.001 } }));

  expect(exitCode).toBe(0);
  expect(out).not.toContain("$");
});

test("hides the ETA without prior samples", async () => {
  const dir = await setup();

  const { exitCode, out } = run(
    dir,
    payload({
      context_window: { context_window_size: 200_000, total_input_tokens: 120_000 },
      session_id: "s2",
    }),
  );

  expect(exitCode).toBe(0);
  expect(out).not.toContain("≈");
});

test("logs a SyntaxError for malformed stdin", async () => {
  const dir = await setup();

  const { exitCode, out } = run(dir, "not json");

  expect(exitCode).toBe(0);
  expect(out).toBe("");
  expect(await Bun.file(`${dir}/statusline.js.log`).text()).toContain("SyntaxError");
});

test("renders the 5h rate-limit segment", async () => {
  const dir = await setup();

  const { exitCode, out } = run(
    dir,
    payload({ rate_limits: { five_hour: { used_percentage: 31.4 } } }),
  );

  expect(exitCode).toBe(0);
  expect(out).toContain("· 5h 31%");
});

test("renders the cost segment", async () => {
  const dir = await setup();

  const { exitCode, out } = run(dir, payload({ cost: { total_cost_usd: 1.2 } }));

  expect(exitCode).toBe(0);
  expect(out).toContain("$1.20");
});

test("renders the ETA from seeded samples", async () => {
  const dir = await setup();
  // A 110k-token climb over the last 2 minutes projects well under the 6h cutoff.
  await Bun.write(
    `${dir}/claude-statusline-s2.json`,
    JSON.stringify({ samples: [{ at: Date.now() - 120_000, tokens: 10_000 }] }),
  );

  const { exitCode, out } = run(
    dir,
    payload({
      context_window: { context_window_size: 200_000, total_input_tokens: 120_000 },
      session_id: "s2",
    }),
  );

  expect(exitCode).toBe(0);
  expect(out).toMatch(/≈\d+(h\d+)?m/);
});

test("renders the model and context percentage", async () => {
  const dir = await setup();

  const { exitCode, out } = run(dir, payload());

  expect(exitCode).toBe(0);
  expect(out.trim().split("\n")).toHaveLength(1);
  expect(out.trim().startsWith("Fable 5.1")).toBe(true);
  expect(out).toMatch(/ \d{1,3}%/);
  expect(pct(out)).toBe(Math.round((50_000 / THRESHOLD) * 100));

  const state = await Bun.file(`${dir}/claude-statusline-s1.json`).json();
  expect(state.samples).toHaveLength(1);
  expect(state.samples[0].tokens).toBe(50_000);
});

test("respects CLAUDE_CODE_AUTO_COMPACT_WINDOW", async () => {
  const dir = await setup();

  const base = run(dir, payload());
  const narrowed = run(dir, payload(), { CLAUDE_CODE_AUTO_COMPACT_WINDOW: "100000" });

  expect(narrowed.exitCode).toBe(0);
  expect(pct(narrowed.out)).toBeGreaterThan(pct(base.out));
  expect(pct(narrowed.out)).toBe(Math.round((50_000 / (100_000 - 20_000 - 13_000)) * 100));
});

test("throttles samples within the same second", async () => {
  const dir = await setup();

  expect(run(dir, payload()).exitCode).toBe(0);
  expect(run(dir, payload()).exitCode).toBe(0);

  const state = await Bun.file(`${dir}/claude-statusline-s1.json`).json();
  expect(state.samples).toHaveLength(1);
});
