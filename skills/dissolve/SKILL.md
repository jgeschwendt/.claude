---
name: dissolve
description: Dissolve the current session into durable memories — extract, verify via one judge subagent, commit through the deterministic commit script (no human review) — then kill the session via the delete skill (transcript archived to the diary, un-resumable).
allowed-tools: Agent, Bash(bash:*), Bash(kill:*), Bash(ls:*), Bash(pwd), Bash(rm:*), Edit, Glob, Grep, Read, Skill, Write
when_to_use: >
  Use at the END of a session that HAD value, to distill the WHOLE conversation into
  durable memories, verify them, and commit them autonomously into
  ~/.claude/@memory/<sanitized-cwd> — the user is NOT involved after invoking. Then kill
  the session. Trigger phrases: "dissolve", "dissolve the session", "dissolve this into
  memory", "capture this session", "/dissolve". This ALWAYS ends the session afterward
  (transcript gzip-archived to the diary, not resumable). If the session had no value,
  use /delete instead (kill without extracting).
---

# Dissolve Session → Committed Memory

Dissolve the WHOLE current conversation into durable memories, verify them through one
judge subagent, and **commit them via the deterministic commit script** into the working
directory's managed bank under `~/.claude/@memory` — then **kill the session by invoking
the delete skill**. The user is not involved after invoking: no review queue, no dashboard
gate. The dashboard remains a viewer/editor, not an approval step.

## Goal

After the session dies, the bank is immaculate: every durable, non-derivable lesson from
this conversation is a committed memory file — judged, deduped against the existing bank,
supersedes applied via `replaces`, index regenerated — and the staged inbox
(`.staging.json`) is drained. Zero ephemeral or code-derivable noise, zero pending human
action. When in doubt about a memory, drop it: with no reviewer downstream, a missed memory
costs less than committed noise.

## Steps

### 1. Resolve the target bank

Compute the bank id from `pwd`: replace every non-alphanumeric character with `-`
(e.g. `/Users/jgeschwendt` → `-Users-jgeschwendt`). The bank lives at
`~/.claude/@memory/<bank-id>/`. First list `~/.claude/@memory/` — if a bank dir already
matches the cwd case-insensitively, reuse its exact existing name (the store has casing
drift; don't create a parallel bank). Never target a bank starting with `_` or `.`, and
never an `auto:` bank (Claude Code's own, read-only) — the commit script enforces this too.

### 2. Load steering + bank index + inbox

Read `~/.claude/@memory/_steering.md` if present; else apply the default steering below.
Read the bank's `MEMORY.md` index (name → file → description of every committed memory).
Read `~/.claude/@memory/.staging.json` (may be `[]` or missing) — its entries are the
**inbox**: write-at-attention memories staged by any prior session (CLAUDE.md § Memory).
Every inbox entry rides this run's pipeline, whatever bank it targets.

**Default steering**: keep only durable memories worth recalling in a future, unrelated
session — `user` (role/preferences/working style), `feedback` (corrections AND validations
the user gave), `project` (ongoing work/goals/constraints not derivable from code or git),
`reference` (pointers to external systems). Do NOT save code patterns/conventions/
architecture/file paths, git history, debugging fix recipes, anything already in CLAUDE.md,
or ephemeral task detail — capture what was _surprising_.

### 3. Extract candidate memories

Dissolve the WHOLE conversation (never a fragment) into 0–N durable memories per the
steering. The test for each: **what would a future, unrelated session do differently for
knowing this?** No concrete answer → not a memory. Each candidate: a human-readable `name`
(≤90 chars), a specific one-line `description`, a `type`, a `body`, and 1–2 short verbatim
`evidence` quotes from the conversation (the judge cannot see this session — evidence is
its only ground truth). For `feedback`/`project`, structure the body as the rule, then a
`**Why:**` line, then a `**How to apply:**` line. Convert relative dates to absolute.
Link related memories with `[[name]]` wikilinks (unresolved links are fine).

**Rules**: one idea per memory — if a rule needs setup paragraphs, it isn't a rule yet;
typical yield is 0–3, and zero is valid — commit nothing rather than manufacture noise.

### 4. Verify — one judge

Launch ONE judge subagent (Agent tool). Its briefing is self-contained (it has zero
context): the candidates with evidence, the steering text verbatim, the bank path, and the
inbox entries (their staged body is their evidence). It reads the committed memory files on
disk, then returns **strict JSON only** — no prose around it:

```json
{
  "verdicts": [
    {
      "name": "...",
      "verdict": "COMMIT|REVISE|DROP",
      "fix": "exact revision if REVISE",
      "reason": "if DROP",
      "duplicate_of": "file.md if already committed",
      "replaces": ["files this supersedes"]
    }
  ],
  "orphaned_obsolete": ["committed files this session contradicted with no replacing candidate"]
}
```

Bars, all must hold for COMMIT: durable (useful in a future, unrelated session) ·
non-derivable (not in code, git, or CLAUDE.md) · one idea · body structure correct for its
type · dates absolute · description specific enough to trigger recall · evidence actually
supports the claim (a memory its own quotes don't support is DROP) · not a duplicate of a
committed file (→ DROP with `duplicate_of`) · supersedes named via `replaces`.

Reconcile: apply each REVISE once and re-check it yourself — still failing → DROP.
Unparseable response → re-ask once; still unparseable → DROP all (fail closed).
`orphaned_obsolete` files are reported in the step-7 summary, never deleted.

### 5. Commit — the script

Write the manifest to the scratchpad and run the committer:

```json
{
  "source": "<session id>",
  "commit": [
    {
      "bank": "...",
      "name": "...",
      "description": "...",
      "type": "...",
      "body": "...",
      "replaces": ["..."]
    }
  ],
  "drop": [{ "bank": "...", "name": "..." }]
}
```

- `commit` = every COMMIT survivor (session candidates + inbox entries alike).
- `drop` = judge-dropped **inbox** entries (so they drain from staging; dropped session
  candidates were never staged and don't need listing).

```
bash ~/.claude/skills/dissolve/scripts/commit-memories.sh <manifest.json>
```

The script deterministically mirrors the dashboard's commit path
(`@apps/web/lib/core/memory.ex` — its header documents the mapping): filenames, collision
suffixes, serialization with bi-temporal `created`/`updated`, `replaces` archival to the
bank's `_archive/`, `MEMORY.md` regen, staging drain — then
**self-verifies** and prints `PASS`/`FAIL`. On FAIL: fix the named issues, re-run once; a
second FAIL → report it plainly in the summary and still proceed to the kill — never hide
a failed commit behind the kill.

### 6. Drain the coding-standards queue

Read `~/.claude/rules/learn-code.md`. If no unchecked entries sit below `<!-- captures below -->`,
skip silently. Otherwise promote each entry that clears the bar — tool-encoded (names config +
rule), a tool default (the default is the universality evidence — verify against the tool's
docs/source), judgment-bearing (not style already delegated to auto-formatting), net-zero
(overlaps an existing rule → merge, don't add) — into `~/.claude/rules/<lang>.md` in house
style, stamped `(since <date> · <tool:rule>)`, each edit shown as a diff. Check off promoted
entries (`- [x]`); strike rejects with a one-line reason (a bespoke override → route it to that
repo's `.claude/`, then strike). Never promote one repo's bespoke rule globally.

### 7. Summary, then kill via /delete

State the one-line summary:

> dissolved: <n> committed, <m> dropped (<reasons, terse>), commit <PASS|FAIL: …>,
> inbox <k> residual, obsolete-orphans: <files or none>

Then **invoke the delete skill** (Skill tool, `delete`) — it stops this session's background
jobs and runs the kill. Do not call its script directly; the kill lives in one place.

**Human checkpoint**: none. Invoking `/dissolve` IS the go-ahead for extraction, commit,
and kill — the summary line is the only user-facing output.

## Notes

- This skill MUST run inline — it reads the current conversation from context. A fork would
  have nothing to dissolve. Only the step-4 judge is a subagent; its briefing must be
  self-contained.
- The commit format's source of truth is `@apps/web/lib/core/memory.ex`; the commit script
  mirrors it. If the app and the script drift, the app wins — update the script (Golden Rule).
- `/dissolve` always kills the session — no extract-only mode. To kill without extracting,
  use `/delete`.
