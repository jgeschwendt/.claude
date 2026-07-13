---
name: dissolve
description: End a session that HAD value — enqueue the whole conversation for memory extraction (the hourly sweep extracts, judges, and commits autonomously), then kill the session via the delete skill (transcript archived to the diary, un-resumable). Fast — no claude calls at session end. Triggers on "dissolve", "dissolve the session", "capture this session", "/dissolve".
allowed-tools: Bash(bash:*), Bash(kill:*), Bash(ls:*), Bash(pwd), Bash(rm:*), Edit, Glob, Grep, Read, Skill, Write
when_to_use: >
  Use at the END of a session that HAD value. It enqueues the conversation into
  ~/.claude/@memory/.dissolve-queue.jsonl and kills the session; the hourly memory
  sweep (mix memory.sweep) later extracts durable memories from the archived
  transcript, judge-verifies them, and commits them into the cwd's bank — the user is
  NOT involved at any point. Trigger phrases: "dissolve", "dissolve the session",
  "dissolve this into memory", "capture this session", "/dissolve". This ALWAYS ends
  the session (transcript gzip-archived to the diary, not resumable). If the session
  had no value, use /delete instead (kill without enqueueing).
---

# Dissolve Session → Queued for Memory

Ending a session must be **instant**: `/dissolve` does no extraction itself. It appends
this session to the dissolve queue and invokes the delete skill; the hourly memory sweep
(`Core.Memory.Sweep` — `@apps/web/lib/core/memory/sweep.ex`) consumes the queue: it reads
the gzip-archived transcript from the diary, extracts candidates, judge-verifies them, and
commits survivors into `~/.claude/@memory/<sanitized-cwd>/` through `Core.Memory` — the
single format authority. No human review anywhere; the dashboard is a viewer/editor.

Run the steps **in order**.

## 1. Stage anything that can't wait for the sweep

Extraction happens on the next sweep run (≤1 h). If this session produced a memory the
**very next session needs** (a correction, a constraint you'd otherwise re-violate), it
should already be staged at the time of attention (CLAUDE.md § Memory). Double-check now:
anything durable and urgent that isn't in an artifact or `.staging.json` yet — stage it.
Usually this is a silent skip.

## 2. Drain the coding-standards queue

Read `~/.claude/rules/learn-code.md`. If no unchecked entries sit below `<!-- captures below -->`,
skip silently. Otherwise promote each entry that clears the bar — tool-encoded (names config +
rule), a tool default (the default is the universality evidence — verify against the tool's
docs/source), judgment-bearing (not style already delegated to auto-formatting), net-zero
(overlaps an existing rule → merge, don't add) — into `~/.claude/rules/<lang>.md` in house
style, stamped `(since <date> · <tool:rule>)`, each edit shown as a diff. Check off promoted
entries (`- [x]`); strike rejects with a one-line reason (a bespoke override → route it to that
repo's `.claude/`, then strike). Never promote one repo's bespoke rule globally.

This is the one judgment task that must stay in-session — the sweep has no skill context.

## 3. Enqueue

```
bash ~/.claude/skills/dissolve/scripts/enqueue.sh "<one-line session title>"
```

Give a title that will make sense in the dashboard's queue panel (what the session was
about, ≤80 chars). The entry records `{id, cwd, title, queued_at}`; the sweep resolves the
bank from the transcript's own cwd (queue cwd is the fallback).

## 4. Summary, then kill via /delete

State the one-line summary:

> queued for dissolve — the hourly sweep will extract and commit; transcript archives to the diary

Then **invoke the delete skill** (Skill tool, `delete`) — it stops this session's background
jobs, archives the transcript (that archive is exactly what the sweep will read), and kills
the session. Do not call its script directly; the kill lives in one place.

**Human checkpoint**: none. Invoking `/dissolve` IS the go-ahead for enqueue and kill.

## Notes

- **Queue consumption contract** (`sweep.ex`): entries are served before idle sessions,
  share the per-run dissolve cap, skip the 48 h quiescence wait. `waiting` (archive not
  flushed yet) and `error` (extraction failed) entries stay queued and retry; `dissolved`,
  `staged`, `trivial` (<4 messages), and `lost` (no archive after 24 h) are consumed.
  Outcomes land in the sweep ledger (`.sweep.jsonl`) and the dashboard's pipeline panel.
- **Resumability**: once /delete finalizes, the live `.jsonl` is gone — un-resumable. The
  gzip in `~/.claude/@log/archive/<date>/` is recoverable by hand (gunzip back into
  `~/.claude/projects/<project>/` restores resumability) and is what the sweep reads.
- `/dissolve` always kills the session — no extract-only mode. To kill without enqueueing,
  use `/delete`. To dissolve an already-dead conversation, use the dashboard's picker.
