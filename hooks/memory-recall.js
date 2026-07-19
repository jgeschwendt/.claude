#!/usr/bin/env bun
// @ts-check
//
// SessionStart hook: inject the cwd's memory bank (plus ancestor banks) as
// additionalContext, so recall never depends on the model remembering to read
// MEMORY.md. Degrades by design: sessions with hooks disabled still have the
// CLAUDE.md § Memory convention; pipeline runs (CLAUDE_MEMORY_PIPELINE=1) get
// nothing, so extraction/judging is never biased by existing memories.
//
// Budget: hook output is capped at 10,000 chars (Claude Code writes overflow to a
// file and injects only a preview) — compose to ~9,000 and degrade per-bank from
// full bodies (user/feedback) to index lines before ever truncating mid-memory.

import { readdirSync, readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

const BUDGET = 9000;
const ROOT = join(homedir(), ".claude", "@memory");

const sanitize = (/** @type {string} */ p) => p.replace(/[^a-zA-Z0-9]/g, "-");

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

function compose(/** @type {string} */ cwd) {
  let banks;
  try {
    banks = readdirSync(ROOT).filter((d) => !d.startsWith(".") && !d.startsWith("_"));
  } catch {
    return "";
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
  if (chain.length === 0) return "";

  const sections = chain
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
          `## Memories · ${label} · ~/.claude/@memory/${bank}/\n` +
          memories.map(fullMode).join("\n"),
        index:
          `## Memory index · ${label} · ~/.claude/@memory/${bank}/\n` +
          memories.map(indexMode).join("\n"),
      };
    })
    .filter(Boolean);
  if (sections.length === 0) return "";

  const header =
    "Recalled memories (committed knowledge from past sessions — background context, " +
    "verify time-sensitive facts before asserting; read the referenced files for full bodies):\n\n";

  // Degrade one bank at a time, farthest ancestor first, until the budget fits.
  const render = (modes) =>
    header + sections.map((s, i) => (modes[i] === "full" ? s.full : s.index)).join("\n\n");
  const modes = sections.map(() => "full");
  for (let i = sections.length - 1; i >= 0 && render(modes).length > BUDGET; i--)
    modes[i] = "index";
  const text = render(modes);
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
