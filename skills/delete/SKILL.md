---
name: delete
description: THE erase — wipe the current conversation outright, no queue pointer, no buffer entry, no extraction, unrecoverable. Stops this session's background jobs, deletes every buffered copy, every live transcript and the pending sidecar, drops a no-route marker so the ending is not routed, then closes the session and erases the exit flush. The privacy ending; every other ending leaves the conversation for triage. There is no softer delete — this verb is always the hard one. Triggers on "/delete", "delete this session", "hard delete this session", "erase this session".
---

# Delete → the conversation is erased

Every other ending routes: the SessionEnd hook mints a `mode: triage` pointer and a 90-day
buffer copy, and reconcile judges the conversation later. This one leaves nothing — for
material that should never have been written down.

Run the steps **in order** — this is live work only a running session can do.

## 1. Stop background jobs — only the ones THIS session started

Do **not** `pkill` by name; other sessions run their own dev servers and tasks. Kill only
processes you launched this session, by their **specific PIDs**. If you started nothing,
say so and move on.

## 2. Erase the conversation

```
~/.orrery/bin/orrery erase
```

It drops the no-route marker first — that is what makes this session's SessionEnd skip
routing instead of queueing a pointer for a transcript that no longer exists — then erases
every buffer copy of this session (an earlier ending's, plus any manual-`/compact` snapshot,
which the buffer holds under a derived `<sid>-compact-<stamp>` id), every live transcript for
it, and the pending sidecar, widest reach first, so an interrupted run leaves the
conversation harder to recover, never easier.

## 3. End the session

**Interactive session:**

```
bash ~/.claude/skills/delete/scripts/delete-session.sh "$CLAUDE_SCRATCHPAD_DIR"
```

(Omit the argument if `$CLAUDE_SCRATCHPAD_DIR` is unset — that just skips scratchpad
cleaning.) The script cleans the scratchpad, resolves **this session's** CLI process
(ancestor-only, never a sibling), detaches a watcher that erases the transcript the CLI
re-creates on its way out, and closes the CLI (Ctrl-C twice, escalating to SIGTERM).

**Background agent** (`claude --bg`) — stop it by its short id, the first 8 characters of
`$CLAUDE_CODE_SESSION_ID`:

```
claude stop <short-id>
```

The no-route marker is what keeps that ending from resurrecting the conversation as a
queue pointer. (verified 2026-07-29 · live probe, Claude Code 2.1.220: `claude stop` fires
`SessionEnd(reason=other)`.)

### Caveats — state them, don't hide them

- **`~/.claude/history.jsonl` survives.** It keeps one line per prompt (cwd + the prompt
  text) and is Claude Code's own file, not orrery's — nothing here touches it. A
  hard-deleted conversation's PROMPTS live there until that file is filtered by hand.
- **A pointer already appended is not retracted.** The queue is an append-only journal, so an
  erase after an earlier routed ending — or after a manual `/compact` — leaves that pointer in
  place; reconcile reports it `waiting`, then `lost` after 24 h, and spends nothing on it.
  Extraction reads the buffer, and every copy this session owns is erased, so nothing is
  extracted from that pointer either way.
- **The exit is best-effort.** The signal is sent from inside a running tool call and the
  CLI may absorb the first interrupt as a turn-cancel. If the script reports "still
  running", tell the user to type `/exit` — the watcher erases the transcript however the
  process ends.
- If the terminal looks wrong after exit (raw mode), `reset` fixes it.

## Completion

State plainly that the conversation is gone and that nothing was kept.

> Conversation erased — no buffer copy left, nothing extractable, not recoverable.
