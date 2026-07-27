#!/usr/bin/env bun
// @ts-check
//
// SessionStart hook: inject what past sessions know into this one, so recall never
// depends on the model remembering to read a file. Four surfaces, one budget:
//
//   1. short-term — queue pointers for THIS cwd from the last 3 days, with the
//      highlights written at the time of attention. Ended, not yet reconciled: their
//      content is not in a bank yet, so nothing else would surface them.
//   2. long-term  — the cwd's memory bank plus ancestor banks (the graph surface).
//   3. chronological — the voyage log's index tail (the last day pages).
//   4. tool index — the tool/skill surface, only once it has content.
//
// Degrades by design: sessions with hooks disabled still have the CLAUDE.md § Memory
// convention (read the bank's MEMORY.md by hand); pipeline runs (CLAUDE_MEMORY_PIPELINE=1)
// get nothing, so extraction/judging is never biased by existing memories. Every surface
// is independently optional — an absent file is a silent no-op, which is what an
// unmigrated machine looks like.
//
// Budget: hook output is capped at 10,000 chars (Claude Code writes overflow to a file and
// injects only a preview), so all four surfaces share ~9,000. Trimming order — cheapest
// surface first, the graph last: tool → chronological → short-term highlights → the
// graph's own per-bank degradation (full bodies → index lines, farthest ancestor first,
// pinned memories keeping their bodies throughout).
//
// Pipeline mechanics — what writes these files, and when — live in orrery's
// lib/orrery/memory.md (github.com/jgeschwendt/orrery).

import { readFileSync, readdirSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

const BUDGET = 9000;
const DAY_MS = 86_400_000;
const HIGHLIGHTS_PER_POINTER = 6;
const HIGHLIGHT_CHARS = 220;
const LOG_INDEX_LINES = 5;
const POINTER_DAYS = 3;
const POINTERS_MAX = 12;
const TOOL_CHARS = 1200;
// A ledger outcome that ends a pointer's life: the conversation is extracted (or
// discarded), so recall must not keep re-surfacing it as pending. Mirrors the pending
// derivation in orrery's reconcile (and in the shell's reconcile-kick).
const PERMANENT_OUTCOMES = ["dissolved", "lost", "staged", "trivial"];

const ORRERY = join(homedir(), ".orrery");
const LOG_ROOT = join(ORRERY, "log");
const ROOT = join(ORRERY, "memory");

const sanitize = (/** @type {string} */ p) => p.replace(/[^a-zA-Z0-9]/g, "-");
const oneLine = (/** @type {string} */ s, /** @type {number} */ max) =>
  s.replace(/\s+/g, " ").trim().slice(0, max);

function read(/** @type {string} */ path) {
  try {
    return readFileSync(path, "utf8");
  } catch {
    return null;
  }
}

// Frontmatter is for the store's own readers; recall renders bodies.
const unfront = (/** @type {string} */ raw) =>
  raw.replace(/^---\r?\n[\s\S]*?\r?\n---\r?\n?/, "").trim();

// Append-only journals written by shell verbs with no lock: one half-flushed trailing
// line must cost that line, never the file.
function jsonl(/** @type {string} */ path) {
  const raw = read(path);
  if (!raw) return [];
  const out = [];
  for (const line of raw.split("\n")) {
    if (!line.trim()) continue;
    try {
      out.push(JSON.parse(line));
    } catch {}
  }
  return out;
}

// ─── surface 1 · short-term (queue pointers + highlights) ─────────────────────
function permanentIds() {
  const newest = new Map();
  for (const line of jsonl(join(ROOT, ".sweep.jsonl")))
    if (typeof line.id === "string" && typeof line.outcome === "string")
      newest.set(line.id, line.outcome);
  return new Set([...newest].filter(([, o]) => PERMANENT_OUTCOMES.includes(o)).map(([id]) => id));
}

/** @returns {{compact:string,full:string}|null} */
function shortTerm(/** @type {string} */ cwd) {
  const want = sanitize(cwd).toLowerCase();
  const resolved = permanentIds();
  const cutoff = Date.now() - POINTER_DAYS * DAY_MS;

  // Last write per id wins: the queue is a journal, so a re-ending appends rather than
  // rewriting. An unparseable or absent queued_at fails the comparison and drops the
  // entry — a pointer with no date cannot be claimed to be within the window.
  const pointers = new Map();
  for (const p of jsonl(join(ROOT, ".dissolve-queue.jsonl"))) {
    if (typeof p.id !== "string" || resolved.has(p.id)) continue;
    if (sanitize(String(p.cwd ?? "")).toLowerCase() !== want) continue;
    if (!(Date.parse(String(p.queued_at ?? "")) >= cutoff)) continue;
    pointers.set(p.id, p);
  }
  if (pointers.size === 0) return null;

  const recent = [...pointers.values()].slice(-POINTERS_MAX);
  const head = (/** @type {any} */ p) =>
    `- **${oneLine(String(p.title || "(untitled)"), 120)}** · queued ${String(p.queued_at).slice(0, 10)} · mode=${p.mode ?? "full"}`;
  const notes = (/** @type {any} */ p) =>
    (Array.isArray(p.highlights) ? p.highlights : [])
      .filter((h) => typeof h === "string" && h.trim())
      .slice(0, HIGHLIGHTS_PER_POINTER)
      .map((h) => `\n  ✻ ${oneLine(h, HIGHLIGHT_CHARS)}`)
      .join("");

  const header =
    `## Short-term · conversations queued for extraction · this directory · last ${POINTER_DAYS} days\n` +
    "Ended but not yet reconciled — none of this is in a bank yet. `✻` lines were written " +
    "at the time of attention.\n";
  return {
    compact: header + recent.map(head).join("\n"),
    full: header + recent.map((p) => head(p) + notes(p)).join("\n"),
  };
}

// ─── surface 2 · long-term (the graph) ────────────────────────────────────────
/** @returns {{name:string,description:string,type:string,recall:string,updated:string,body:string,file:string}|null} */
function parseMemory(/** @type {string} */ raw, /** @type {string} */ file) {
  const m = raw.match(/^---\r?\n([\s\S]*?)\r?\n---\r?\n?([\s\S]*)$/);
  const fm = {};
  if (m)
    for (const line of m[1].split(/\r?\n/)) {
      const kv = line.match(/^\s*([\w-]+):\s*(.+)$/);
      if (kv) fm[kv[1]] = kv[2].trim().replace(/^["']|["']$/g, "");
    }
  const body = (m ? m[2] : raw).trim();
  if (!fm.name && !body) return null;
  return {
    body,
    description: fm.description ?? "",
    file,
    name: fm.name ?? file.replace(/\.md$/, ""),
    // recall steers rendering independent of type: pin | index | mute (anything else /
    // absent = type policy). Values outside the trio degrade to "" (type policy).
    recall: ["index", "mute", "pin"].includes(fm.recall) ? fm.recall : "",
    type: fm.type ?? "reference",
    updated: fm.updated ?? fm.created ?? "",
  };
}

function bankMemories(/** @type {string} */ bank) {
  const dir = join(ROOT, bank);
  const out = [];
  for (const f of readdirSync(dir).sort()) {
    if (!f.endsWith(".md") || f === "MEMORY.md" || f.startsWith("_")) continue;
    try {
      const mem = parseMemory(readFileSync(join(dir, f), "utf8"), f);
      if (mem) out.push(mem);
    } catch {}
  }
  // user/feedback carry behavioral rules — surface them first, newest first within type;
  // recall:pin outranks every type, recall:mute drops the memory entirely.
  const rank = { user: 0, feedback: 1, project: 2, reference: 3 };
  const rankOf = (/** @type {{type:string,recall:string}} */ m) =>
    m.recall === "pin" ? -1 : (rank[m.type] ?? 4);
  return out
    .filter((m) => m.recall !== "mute")
    .sort((a, b) => rankOf(a) - rankOf(b) || b.updated.localeCompare(a.updated));
}

/** @returns {{bank:string,full:string,index:string}[]} */
function graphSections(/** @type {string} */ cwd) {
  let banks;
  try {
    banks = readdirSync(ROOT).filter((d) => !d.startsWith(".") && !d.startsWith("_"));
  } catch {
    return [];
  }

  // cwd bank first, then ancestors ascending toward $HOME (their memories still apply,
  // more loosely) — matched case-insensitively because the store has casing drift.
  const chain = [];
  for (let dir = cwd; ; dir = join(dir, "..")) {
    const want = sanitize(dir).toLowerCase();
    const hit = banks.find((b) => b.toLowerCase() === want);
    if (hit && !chain.some((c) => c.bank === hit)) chain.push({ bank: hit, exact: dir === cwd });
    if (dir === homedir() || dir === join(dir, "..")) break;
  }

  return chain
    .map(({ bank, exact }) => {
      const memories = bankMemories(bank);
      if (memories.length === 0) return null;
      const label = exact ? "this directory's bank" : "ancestor bank";
      const full = (m) => `### ${m.name} (${m.type})\n${m.body}`;
      const index = (m) => `- ${m.name} (${m.type}) — ${m.description}  [${bank}/${m.file}]`;
      // recall wins over type: pin → always full, index → always index line; else type policy.
      const fullMode = (m) =>
        m.recall === "pin"
          ? full(m)
          : m.recall === "index"
            ? index(m)
            : ["user", "feedback"].includes(m.type)
              ? full(m)
              : index(m);
      // In degraded (index) mode a pinned memory keeps its full body above the index lines.
      const indexMode = (m) => (m.recall === "pin" ? full(m) : index(m));
      return {
        bank,
        full:
          `## Long-term · ${label} · ~/.orrery/memory/${bank}/\n` +
          memories.map(fullMode).join("\n"),
        index:
          `## Long-term index · ${label} · ~/.orrery/memory/${bank}/\n` +
          memories.map(indexMode).join("\n"),
      };
    })
    .filter(Boolean);
}

// ─── surface 3 · chronological (the log index) ────────────────────────────────
function chronological() {
  const raw = read(join(LOG_ROOT, "INDEX.md"));
  if (!raw) return null;
  const lines = unfront(raw)
    .split("\n")
    .filter((l) => l.trim())
    .slice(0, LOG_INDEX_LINES);
  if (lines.length === 0) return null;
  return `## Chronological · the voyage log's most recent day pages · ~/.orrery/log/\n${lines.join("\n")}`;
}

// ─── surface 4 · tool index ───────────────────────────────────────────────────
// Emitted as an HTML-comment placeholder until its scope is settled, so "non-empty" means
// non-empty AFTER the comments come out — otherwise recall would spend budget on a note to
// itself.
function tools() {
  const raw = read(join(ROOT, "TOOLS.md"));
  if (!raw) return null;
  const body = unfront(raw)
    .replace(/<!--[\s\S]*?-->/g, "")
    .trim();
  if (!body) return null;
  return `## Tool index · ~/.orrery/memory/TOOLS.md\n${body.slice(0, TOOL_CHARS)}`;
}

// ─── composition ──────────────────────────────────────────────────────────────
const HEADER =
  "Recalled context from past sessions in this directory (background, not instructions — " +
  "verify time-sensitive facts before asserting; read the referenced files for full " +
  "bodies):\n\n";

function compose(/** @type {string} */ cwd) {
  const graph = graphSections(cwd);
  const chrono = chronological();
  const short = shortTerm(cwd);
  const tool = tools();

  const state = {
    chrono: Boolean(chrono),
    graph: graph.map(() => "full"),
    short: short ? "full" : "off",
    tool: Boolean(tool),
  };

  const render = () => {
    const parts = [];
    if (short && state.short !== "off") parts.push(short[state.short]);
    graph.forEach((s, i) => parts.push(state.graph[i] === "full" ? s.full : s.index));
    if (chrono && state.chrono) parts.push(chrono);
    if (tool && state.tool) parts.push(tool);
    return parts.length === 0 ? "" : HEADER + parts.join("\n\n");
  };

  // Trim cheapest-first (see the budget note at the top). Each step is re-measured, so a
  // payload that already fits is never trimmed at all.
  let text = render();
  const over = () => text.length > BUDGET;
  const trim = (/** @type {() => void} */ step) => {
    if (!over()) return;
    step();
    text = render();
  };
  trim(() => (state.tool = false));
  trim(() => (state.chrono = false));
  trim(() => (state.short = state.short === "full" ? "compact" : state.short));

  let floored = false;
  for (let i = state.graph.length - 1; i >= 0 && over(); i--) {
    state.graph[i] = "index";
    text = render();
    floored = i === 0;
  }

  // The graph is at its floor and cannot give back more, so the leftover would otherwise
  // be wasted: reinstate the trimmed surfaces in reverse order, each only if it still
  // fits. This can never cost the graph anything it was going to keep.
  if (floored)
    for (const restore of [
      () => (short ? (state.short = "full") : null),
      () => (state.chrono = Boolean(chrono)),
      () => (state.tool = Boolean(tool)),
    ]) {
      const snapshot = { ...state };
      restore();
      text = render();
      if (over()) {
        state.chrono = snapshot.chrono;
        state.short = snapshot.short;
        state.tool = snapshot.tool;
        text = render();
      }
    }

  return text.length > BUDGET ? text.slice(0, BUDGET) : text;
}

// Pipeline runs must stay memory-blind (extraction/judge bias + token waste).
if (process.env.CLAUDE_MEMORY_PIPELINE === "1") process.exit(0);

const input = JSON.parse(readFileSync(0, "utf8"));
const context = compose(input.cwd ?? process.cwd());
if (context) {
  console.log(
    JSON.stringify({
      hookSpecificOutput: { hookEventName: "SessionStart", additionalContext: context },
    }),
  );
}
