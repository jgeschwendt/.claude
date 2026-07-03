---
name: dissolve
description: Dissolve the current session into durable memories — extract, verify via a subagent harness, and COMMIT directly into the cwd's memory bank (no human review) — then kill the session (compact-delete transcript, gzip-archived to the diary, un-resumable).
allowed-tools: Agent, Bash(bash:*), Bash(kill:*), Bash(ls:*), Bash(pwd), Bash(rm:*), Edit, Glob, Grep, Read, Write
when_to_use: >
  Use at the END of a session that HAD value, to distill the WHOLE conversation into
  durable memories, verify them, and commit them autonomously into
  ~/.claude/@memory/<sanitized-cwd> — the user is NOT involved after invoking. Then kill
  the session. Trigger phrases: "dissolve", "dissolve the session", "dissolve this into
  memory", "capture this session", "/dissolve". This ALWAYS ends the session afterward
  (compact-deletes the transcript — gzip-archived to the diary, not resumable). If the
  session had no value, use /delete instead (kill without extracting).
---

# Dissolve Session → Committed Memory

Dissolve the WHOLE current conversation into durable memories, verify them through a
subagent harness, and **commit them directly** into the working directory's managed bank
under `~/.claude/@memory` — then **kill the session** (compact-delete its transcript,
un-resumable; the raw `.jsonl` gzip-archives under `~/.claude/@log/archive/`, fuel for the
diary's daily dream). The user is not involved after invoking: no review queue, no
dashboard gate. The dashboard remains a viewer/editor, not an approval step.

## Goal

After the session dies, the bank is immaculate: every durable, non-derivable lesson from
this conversation is a committed memory file — verified, deduped against the existing bank,
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
drift; don't create a parallel bank).

**Success criteria**: A single correct bank id and absolute path. The dir need not exist yet.

**Rules**:

- Never target or create a bank whose name starts with `_` or `.` — the dashboard skips those.
- Never write to an `auto:` bank — those are Claude Code's own, read-only.

### 2. Load steering + existing memories + inbox

Read `~/.claude/@memory/_steering.md` if present; else apply the default steering below.
Then read every `*.md` in the bank except `MEMORY.md` and `_`-prefixed files, capturing
each memory's `name`, `description`, `type`, and filename. Read `~/.claude/@memory/.staging.json`
(may be `[]` or missing) — its entries are the **inbox**: write-at-attention memories staged by
any prior session (CLAUDE.md § Memory). Every inbox entry rides this run's pipeline —
verified and committed alongside this session's candidates, whatever bank it targets.

**Success criteria**: You hold the active steering text, an inventory of existing committed
memories (name → filename) for every bank you will touch, and the full inbox.

**Default steering**: keep only durable memories worth recalling in a future, unrelated
session — `user` (role/preferences/working style), `feedback` (corrections AND validations
the user gave), `project` (ongoing work/goals/constraints not derivable from code or git),
`reference` (pointers to external systems). Do NOT save code patterns/conventions/
architecture/file paths, git history, debugging fix recipes, anything already in CLAUDE.md,
or ephemeral task detail — instead capture what was _surprising_.

### 3. Extract candidate memories

Dissolve the WHOLE conversation (never a fragment) into 0–N durable memories per the steering.
Each memory: a human-readable `name` (≤90 chars), a specific one-line `description`, a `type`,
a `body`, and 1–2 short verbatim `evidence` quotes from the conversation (the verifiers
cannot see this session — evidence is their only ground truth). For `feedback`/`project`,
structure the body as the rule/memory, then a `**Why:**` line, then a `**How to apply:**` line.
Convert all relative dates to absolute using today's date from context. Author `[[wikilink]]`
references to related memories by their `name` slug.

**Success criteria**: A candidate list where every entry is durable, non-derivable,
correctly structured, and evidence-backed. Zero candidates is valid — commit nothing rather
than manufacture noise.

**Rules**:

- Dissolve the whole conversation, not fragments — nothing captured out of context.
- One idea per memory. If a rule needs setup paragraphs to make sense, it isn't a rule yet — cut it.
- Link liberally with `[[name]]`; an unresolved link is fine (it marks a future memory).

### 4. Verify — the harness

Launch two judges **in parallel, in a single message** (Agent tool). Each briefing is
self-contained: the judges have zero context, so include everything they need verbatim.

- **Quality judge** — receives the candidates (with evidence) + the steering text. Per
  memory, one verdict: `COMMIT` | `REVISE: <exact fix>` | `DROP: <reason>`. Bars, all must
  hold: durable (useful in a future, unrelated session) · non-derivable (not in code, git,
  or CLAUDE.md) · one idea · body structure correct for its type · dates absolute ·
  description specific enough to trigger recall · evidence actually supports the claim
  (a memory its own quotes don't support is `DROP`).
- **Dedup judge** — receives the candidates + the bank path(s). It reads the committed
  memory files on disk. Per memory, one verdict: `NEW` | `DUP: <file>` | `SUPERSEDES: <files>`.
  It also lists committed memories this session contradicted that have NO replacing candidate
  (orphaned-obsolete) — those are reported in the step-8 summary line, never deleted.

Reconcile inline: apply each `REVISE` once and re-check it yourself; an entry that still
fails → `DROP`. `DUP` → drop the candidate. `SUPERSEDES` → set the candidate's `replaces`
to those filenames. Inbox entries go through the same two judges as session candidates
(their `evidence` is their staged body — judge internal coherence and dedup only).

**Success criteria**: Every surviving candidate carries an explicit `COMMIT` from the
quality judge and a `NEW`/`SUPERSEDES` from the dedup judge. Nothing commits on your own
sole judgment.

### 5. Commit

Write each survivor directly into its bank, mirroring the dashboard's commit exactly
(source of truth: `@apps/web/lib/core/memory.ex` — `serialize_memory/1`, `commit_file_name/2`,
`regen_index/1`, `commit_memory/1`; on any drift, the code wins — re-read it):

1. **Filename** `<type>_<slug>.md` — slug = name downcased, `[^a-z0-9]+` → `_`, trimmed of
   `_`, max 60 chars. If the target file exists and holds a DIFFERENT memory (parsed `name`
   differs) that this commit does not replace, suffix `_2`, `_3`, … — never clobber.
2. **File content** — exactly:

   ```
   ---
   name: <name>
   description: <description, whitespace collapsed to single spaces>
   type: <feedback|project|reference|user>
   source: <session id — omit the line if unknown>
   ---

   <trimmed body>
   ```

   (one trailing newline)

3. **Replaces** — `rm` each replaced filename (plain filenames inside the bank only — never
   a path with `/` or `..`).
4. **Index** — regenerate the bank's `MEMORY.md`: the fixed frontmatter header
   (`name: MEMORY index` / `description: One-line map of all durable memories in this knowledge bank` /
   `type: reference`), then one line per memory file in **sorted filename order**:
   `- [<name>](<file>) — <description, whitespace-collapsed, ≤150 chars>`.
5. **Drain the inbox** — rewrite `.staging.json` keeping only entries NOT committed and NOT
   dropped this run (match on `bank`+`name`). Committed and judge-dropped entries leave the
   inbox; a malformed entry (no name/bank) is dropped with a note in the summary.

**Success criteria**: Every survivor is a memory file on disk in dashboard-compatible format;
replaced files are gone; each touched bank's `MEMORY.md` is regenerated; the inbox holds
only entries that legitimately await a future run (normally none).

### 6. Audit — independent verification

Spawn ONE fresh auditor subagent (zero context). Give it: the bank path(s), the expected
manifest (committed filenames + names + descriptions, replaced files that must be absent,
inbox residue expected in `.staging.json`), and the format spec from step 5. It re-reads
the disk and verifies: every committed file parses with valid frontmatter and a legal type ·
filenames obey the slug rule · `MEMORY.md` lists exactly the bank's memory files, sorted, with
matching names/descriptions · replaced files are absent · `.staging.json` is valid JSON with
exactly the expected residue. Verdict: `PASS` | `FAIL: <numbered issues>`.

On `FAIL`: fix each issue inline, then re-run the auditor once. A second `FAIL` → leave the
bank in its most consistent state and name the unresolved issues plainly in the step-8
summary — never hide a failed audit behind the kill.

**Success criteria**: An explicit `PASS` from the auditor (or a plainly-reported failure).
You do not self-certify: only the auditor's verdict closes this step.

### 7. Drain the coding-standards queue

Read `~/.claude/rules/learn-code.md`. If no unchecked entries sit below `<!-- captures below -->`,
skip silently. Otherwise promote each entry that clears the bar — tool-encoded (names config +
rule), a tool default (the default is the universality evidence — verify against the tool's
docs/source), judgment-bearing (not style already delegated to auto-formatting), net-zero
(overlaps an existing rule → merge, don't add) — into `~/.claude/rules/<lang>.md` in house
style, stamped `(since <date> · <tool:rule>)`, each edit shown as a diff. Check off promoted
entries (`- [x]`); strike rejects with a one-line reason (a bespoke override → route it to that
repo's `.claude/`, then strike). Create a missing `rules/<lang>.md` by mirroring
`rules/typescript.md` (correct `paths:` frontmatter).

**Success criteria**: The queue is empty — every entry promoted or struck — and no repo-bespoke
setting entered the global rules.

**Rules**:

- Never promote one repo's bespoke rule globally — it belongs in that repo's `.claude/`.

### 8. Kill the session

End the session. First state the one-line summary — `dissolved: <n> committed, <m> dropped
(<reasons, terse>), audit <PASS|FAIL: …>, inbox <k> residual, obsolete-orphans: <files or none>` —
then stop any background jobs THIS session started (kill them by their specific PIDs — never
`pkill` by name). Then run the shared kill helper:

```
bash ~/.claude/skills/delete/scripts/delete-session.sh
```

The helper finds this session's transcript (`~/.claude/projects/*/$CLAUDE_CODE_SESSION_ID.jsonl`),
spawns a detached `setsid` watcher that gzip-archives it to `~/.claude/@log/archive/<date>/`
(and removes any handoff) **after** the CLI process exits — archiving the live file directly
would just be recreated on the way out — then closes the session (Ctrl-C twice, escalating
to SIGTERM).

**Success criteria**: The transcript is scheduled to be compact-deleted (archived) on exit
and the session closes; `claude --resume <sid>` will fail (no live transcript). The committed
memories live in the bank(s), indexed and audit-verified.

**Human checkpoint**: None. Invoking `/dissolve` IS the go-ahead for extraction, commit, and
kill — proceed without re-confirming; the summary line is the only user-facing output.

**Rules**:

- `/dissolve` always kills the session — there is no extract-only mode. To kill without
  extracting, use `/delete`. Both share `delete-session.sh` and are equally un-resumable.

## Notes

- This skill MUST run inline — it reads the current conversation from context. A fork would
  have nothing to dissolve. Only the judges (step 4) and the auditor (step 6) are subagents,
  and their briefings must be self-contained.
- The commit format's source of truth is `@apps/web/lib/core/memory.ex`. If the app and this
  file disagree, the code wins — update this file (Golden Rule).
- The dashboard is a viewer/editor over the same files; nothing in this pipeline waits on it.
