---
name: delete
description: Kill the current Claude Code session — stop the background jobs this session started, route the conversation for salvage-only triage (a `mode: salvage` queue pointer plus a gzip copy in the 90-day buffer), finalize the transcript (un-resumable), and exit; wrapped sessions respawn a fresh ephemeral fork in the same terminal. Zero claude calls at the ending — reconcile does the triage, keeping only instruction-shaped content and erasing a valueless transcript. Use /dissolve instead when the session had value (full extraction). "/delete hard" erases the conversation outright — no pointer, no buffer, unrecoverable. Triggers on "/delete", "/delete hard", "delete the session", "hard delete this session", "kill this session", "wrap up and exit".
---

# Delete Session

Kill the current session and make it un-resumable. `/delete` is **not** "no extraction": the
conversation is routed for **salvage-only triage** — reconcile keeps only
instruction-shaped content (a long-term memory or a code-plan proposal) and hard-deletes a
transcript with no value at all, buffer entry included. Use it when the session had **no
lasting value as a whole**; if it did, use `/dissolve` (full extraction — it routes the
conversation, then invokes this skill to do the kill).

`/delete hard` is the one ending that leaves nothing: no pointer, no buffer entry, zero
tokens, unrecoverable.

Run the steps **in order** — this is live work only a running session can do.

## 1. Stop background jobs — only the ones THIS session started

Do **not** `pkill` by name — other sessions run their own dev servers and tasks. Kill only
processes you launched this session, by their **specific PIDs** (background shells, tasks,
dev servers you started). If you started nothing, say so and move on.

## 2. Route the conversation

**Skip this whole step when the caller says the conversation is already routed** — that is
how `/dissolve` invokes this skill, and one conversation gets exactly one pointer. (If it
happens anyway the damage is bounded: the queue dedups by id, first occurrence wins, so the
earlier `full` pointer survives — but the queue keeps the junk line forever.)

Soft delete (the default) — a `mode: salvage` pointer plus the buffer copy:

```
ORRERY_BUFFER_KEEP_LIVE=1 bash ~/.claude/skills/dissolve/scripts/enqueue-v2.sh salvage "<one-line session title>"
```

The script appends the pointer, adopts and deletes this session's pending sidecar (its
highlights ride the pointer), gzip-copies the transcript into `~/.orrery/buffer/<date>/`,
and kicks a minor reconcile once the queue's pending depth crosses the threshold.
`ORRERY_BUFFER_KEEP_LIVE=1` leaves the live transcript for step 3 to finalize — the kill
owns that removal, not the routing.

When the user said **"/delete hard"** / "hard delete this session", **erase instead of
routing** — no pointer, nothing for reconcile to read:

```
bash ~/.claude/skills/delete/scripts/delete-hard-v2.sh
```

It erases every buffer copy of this session, every live transcript for it, and the pending
sidecar — widest reach first, so an interrupted run leaves the conversation harder to
recover, never easier. It does **not** touch `~/.claude/history.jsonl`, which keeps one line
per prompt (cwd + prompt text) — Claude Code's own file, filterable only by hand.
(verified 2026-07-27 · orrery `planning/hook-probe-2026-07-27.md` §5)

## 3. Kill the session

```
bash ~/.claude/skills/delete/scripts/delete-session.sh "$CLAUDE_SCRATCHPAD_DIR"
```

(If `$CLAUDE_SCRATCHPAD_DIR` isn't set, omit the arg to skip scratchpad cleaning.)

Under **"/delete hard"**, pass `--hard` first (flag before the scratchpad arg) so the
transcript's final flush is erased rather than archived:

```
bash ~/.claude/skills/delete/scripts/delete-session.sh --hard "$CLAUDE_SCRATCHPAD_DIR"
```

The script: cleans the scratchpad → resolves **this session's** CLI process (ancestor-only,
never a sibling) → archives the transcript(s) NOW (`archive-transcript.sh --now`; **skipped
under `--hard`**) → writes the archive-on-exit marker → exits the CLI (Ctrl-C twice,
escalating to SIGTERM). Post-exit finalize (soft: re-archive the final flush then remove the
live `.jsonl`; `--hard`: remove it with no archive copy — plus handoff + marker either way)
happens by one of two paths:

- A detached `nohup` watcher always finalizes after the CLI dies (idempotent via lock).
- **Wrapped sessions** (`skills/delete/claude.zsh` sourced in `.zshrc` sets `CLAUDE_WRAPPER_STATE`)
  additionally **respawn a fresh claude in the same terminal as an ephemeral fork** —
  pre-marked archive-on-exit, so however it ends (even plain `/exit`) its transcript
  finalizes. To keep a fork after all:
  `rm ~/.orrery/archive/.archive-on-exit/$CLAUDE_CODE_SESSION_ID`. Unwrapped sessions don't respawn.

### Caveats — state them, don't hide them

- **Un-resumable, but not gone.** Soft delete leaves the conversation in the 90-day buffer
  (`~/.orrery/buffer/<date>/<session-id>.jsonl.gz` — reconcile's input; `gunzip` it back
  into `~/.claude/projects/<project>/` to make it resumable again). Highlights taken during
  the session ride the pointer, so they survive the kill. The kill's own archive copy under
  `~/.orrery/archive/<date>/` is v1 residue and retires with v1's sweep.
- **`--hard` erases outright.** Not buffered, not pointered, not recoverable, and never
  feeds the day page. Everything else (kill sequence, wrapper respawn) is identical to soft
  delete. **`/dissolve` must NEVER use `--hard`** — it would erase the buffer copy reconcile
  is about to read. (since 2026-07-19 · /delete hard)
- **A pointer already appended is not retracted.** The queue is an append-only journal, so a
  hard delete after a soft one leaves the earlier pointer in place; reconcile reports it
  `waiting`, then flags it `questionable` after 3 days, and spends nothing on it.
- **The exit is best-effort.** The signal is sent from inside a running tool call; the CLI may
  absorb the first interrupt as a turn-cancel. If the script reports "still running," tell the
  user to type `/exit` — the marker guarantees the transcript finalizes however the CLI exits.
- **Background sessions (no TTY — `claude -p`, background jobs) cannot self-terminate**: the
  signals are absorbed, so the script detects the missing TTY and reports "operator must stop
  the job" instead of pretending to close (2026-07-21 work-machine report). The pointer,
  buffer copy and marker are already secured, so routing and finalize work regardless of how
  the process eventually ends.
- If the terminal looks wrong after exit (raw mode), `reset` fixes it.

## Completion

State plainly what happened to the conversation and that it is not resumable. Do **not**
print a resume command — there's nothing to resume.

> Session killed — routed for salvage triage (90-day buffer), not resumable.

Under `--hard`:

> Session killed — conversation erased outright, not recoverable.
