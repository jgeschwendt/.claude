---
name: delete
description: Kill the current Claude Code session — stop the background jobs this session started, archive its transcript to the archive immediately (un-resumable), and exit; wrapped sessions respawn a fresh ephemeral fork in the same terminal. No memory extraction; use /dissolve if the session had value. "/delete hard" erases the transcript outright instead of archiving (unrecoverable). Triggers on "/delete", "/delete hard", "delete the session", "hard delete this session", "kill this session", "wrap up and exit".
---

# Delete Session

Kill the current session: archive its transcript to the archive **immediately**, make it
un-resumable, and exit. The raw `.jsonl` is gzip-archived under `~/.orrery/archive/<date>/`
(recoverable, fuel for the archive's daily dream) — but `claude --resume` will fail once the
live file is finalized away. Use this when the session had **no** lasting value; if it did,
use `/dissolve` (enqueues the conversation for the memory sweep's extraction, then invokes
this skill — the archive written here is what the sweep reads).

Run the steps **in order** — this is live work only a running session can do.

## 1. Stop background jobs — only the ones THIS session started

Do **not** `pkill` by name — other sessions run their own dev servers and tasks. Kill only
processes you launched this session, by their **specific PIDs** (background shells, tasks,
dev servers you started). If you started nothing, say so and move on.

## 2. Kill the session

```
bash ~/.claude/skills/delete/scripts/delete-session.sh "$CLAUDE_SCRATCHPAD_DIR"
```

(If `$CLAUDE_SCRATCHPAD_DIR` isn't set, omit the arg to skip scratchpad cleaning.)

When the user said **"/delete hard"** / "hard delete this session", pass `--hard` first (flag
before the scratchpad arg): the transcript is **erased outright** — no archive copy,
unrecoverable.

```
bash ~/.claude/skills/delete/scripts/delete-session.sh --hard "$CLAUDE_SCRATCHPAD_DIR"
```

The script: cleans the scratchpad → resolves **this session's** CLI process (ancestor-only,
never a sibling) → archives the transcript(s) NOW (`archive-transcript.sh --now`; **skipped
under `--hard`**) → writes the archive-on-exit marker → exits the CLI (Ctrl-C twice, escalating
to SIGTERM). Post-exit finalize (soft: re-archive the final flush then remove the live `.jsonl`;
`--hard`: remove it with no archive copy — plus handoff + marker either way) happens by
one of two paths:

- A detached `nohup` watcher always finalizes after the CLI dies (idempotent via lock).
- **Wrapped sessions** (`skills/delete/claude.zsh` sourced in `.zshrc` sets `CLAUDE_WRAPPER_STATE`)
  additionally **respawn a fresh claude in the same terminal as an ephemeral fork** —
  pre-marked archive-on-exit, so however it ends (even plain `/exit`) its transcript
  dissolves to the archive. To keep a fork after all:
  `rm ~/.orrery/archive/.archive-on-exit/$CLAUDE_CODE_SESSION_ID`. Unwrapped sessions don't respawn.

### Caveats — state them, don't hide them

- **Un-resumable.** Archived to the archive (recoverable there), not erased. Memories already
  staged at the time of attention (CLAUDE.md § Memory) survive — staging is a file, untouched
  by the kill. Only un-staged residue is lost; if that residue has value, use `/dissolve`.
- **`--hard` erases outright.** The transcript is **not** in the archive, **not** recoverable,
  and **never feeds the voyage log**. Everything else (kill sequence, wrapper respawn, staged
  memories surviving) is identical to soft delete. **`/dissolve` must NEVER use `--hard`** — the
  archive is exactly what the hourly sweep reads, so a hard dissolve would extract nothing.
  (since 2026-07-19 · /delete hard)
- **The exit is best-effort.** The signal is sent from inside a running tool call; the CLI may
  absorb the first interrupt as a turn-cancel. If the script reports "still running," tell the
  user to type `/exit` — the marker guarantees the transcript finalizes however the CLI exits.
- **Background sessions (no TTY — `claude -p`, background jobs) cannot self-terminate**: the
  signals are absorbed, so the script detects the missing TTY and reports "operator must stop
  the job" instead of pretending to close (2026-07-21 work-machine report). Archive + marker
  are still secured, so extraction/finalize work regardless of how the process eventually ends.
- If the terminal looks wrong after exit (raw mode), `reset` fixes it.

## Completion

State plainly that the conversation is archived to the archive and not resumable. Do **not**
print a resume command — there's nothing to resume.

> Session killed — transcript archived to the archive, not resumable.
