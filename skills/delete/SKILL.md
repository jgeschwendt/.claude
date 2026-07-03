---
name: delete
description: Kill the current Claude Code session — stop the background jobs this session started, then compact-delete its transcript (gzip-archived to the diary, un-resumable) and exit. No memory extraction; use /dissolve if the session had value. Triggers on "/delete", "delete the session", "kill this session", "wrap up and exit".
---

# Delete Session

Kill the current session: compact-delete its transcript so it can't be resumed, then exit.
Compact-delete means the raw `.jsonl` is gzip-archived under `~/.claude/@log/archive/`
(recoverable, and fuel for the diary's daily dream) rather than erased — but the session
is still un-resumable, since `claude --resume` needs a live transcript. Use this when the
session had **no** lasting value. If it did, use `/dissolve` instead — that extracts
durable memories first, then kills the session the same way.

Run the steps **in order** — each is live work done while the session is still
alive (no hook can do this; `SessionEnd` runs too late and can't reason or interact).

## 1. Stop background jobs — only the ones THIS session started

Do **not** `pkill` by name — other sessions run their own dev servers and tasks.
Kill only processes you launched this session:

- List your own background shells/tasks (the ones you started via `run_in_background`
  or background skills like `dev`). Kill them by their **specific PIDs**.
- Only kill a dev server if you started it this session — match the exact PID, not
  the command name.

If you started nothing in the background, say so and move on.

## 2. Kill the session

Run the helper (pass the scratchpad dir so it's cleared too):

```
bash ~/.claude/skills/delete/scripts/delete-session.sh "$CLAUDE_SCRATCHPAD_DIR"
```

(If `$CLAUDE_SCRATCHPAD_DIR` isn't set, omit the arg to skip scratchpad cleaning.)

The script resolves **this session's** CLI process (ancestor-only — never another
session), spawns a detached watcher that compact-deletes this session's transcript(s)
(`~/.claude/projects/*/$CLAUDE_CODE_SESSION_ID.jsonl` → gzip-archived under
`~/.claude/@log/archive/<date>/`) and removes any stale handoff **after** the CLI exits
— archiving the live file directly would just be recreated — then exits by simulating
Ctrl-C-twice, escalating to `SIGTERM`.

### Caveats — state them, don't hide them

- **This is un-resumable.** The transcript is gzip-archived to the diary (recoverable
  there), not erased — but `claude --resume` will fail, since it needs a live transcript.
  Memories already staged at the time of attention (CLAUDE.md § Memory) survive — staging is
  a file, untouched by the kill. Only un-staged residue is lost; if that residue has
  value, use `/dissolve` instead.
- **The exit is best-effort.** The signal is sent from inside a running tool call; the
  CLI may absorb the first interrupt as a turn-cancel. If the script reports "still
  running," tell the user to type `/exit` — the transcript still deletes once the
  process exits.
- **No skill/hook/model can _guarantee_ CLI termination** — this simulates the user's
  own Ctrl-C.
- If the terminal looks wrong after exit (raw mode), `reset` fixes it.

## Completion

State plainly that the conversation is being compact-deleted (archived to the diary) and
is not resumable. Do **not** print a resume command — there's nothing to resume.

> Session killed — transcript archived to the diary, not resumable.
