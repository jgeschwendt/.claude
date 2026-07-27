---
name: dissolve
description: End a session that HAD value — route the whole conversation for memory extraction (a `mode: full` queue pointer plus a gzip copy in the 90-day buffer), then kill the session via the delete skill (un-resumable). Zero claude calls at the ending; orrery's reconcile pass extracts, judges, and commits afterwards. Triggers on "dissolve", "dissolve the session", "capture this session", "/dissolve".
allowed-tools: Bash(bash:*), Bash(kill:*), Bash(ls:*), Bash(pwd), Bash(rm:*), Edit, Glob, Grep, Read, Skill, Write
when_to_use: >
  Use at the END of a session that HAD value. It appends a `mode: full` pointer to
  ~/.orrery/memory/.dissolve-queue.jsonl, copies the conversation into the 90-day buffer,
  adopts this session's pending highlights into that pointer, and kills the session;
  orrery's reconcile pass then extracts durable memories from the buffered copy,
  judge-verifies them, and commits them into the cwd's bank — the user is NOT involved at
  any point. Trigger phrases: "dissolve", "dissolve the session", "dissolve this into
  memory", "capture this session", "/dissolve". This ALWAYS ends the session
  (un-resumable). If the session had no value, use /delete instead — that still routes the
  conversation, but for salvage-only triage.
---

# Dissolve Session → routed for extraction

Ending a session must be **instant**: `/dissolve` spends zero tokens and makes no routing
decision. It appends a pointer to the queue, copies the conversation into the 90-day
buffer, and invokes the delete skill. Everything expensive happens later, in orrery's
**reconcile** pass (`mix orrery.reconcile` — orrery `lib/orrery/reconcile.ex`; its cadence
and wiring are that repo's business): reconcile reads the buffered copy, extracts
candidates, routes each one — long-term commit · code-plan proposal · stele-edit proposal ·
chronological mention · drop — and commits survivors into `~/.orrery/memory/<bank>/`
through `Orrery.Memory`, the single format authority. No human review anywhere; the
dashboard is a viewer/editor.

Run the steps **in order**.

## 1. Note anything the extractor must not miss

Extraction reads the whole conversation, so nothing needs summarizing here. But a durable
memory that surfaced mid-session should already be a highlight line on this session's
pending sidecar (CLAUDE.md § Memory) — those lines ride the pointer as pre-extracted
candidates. Double-check now: anything durable that is in neither an artifact nor the
sidecar gets one line each.

```
bash ~/.claude/skills/dissolve/scripts/attend-v2.sh "<one durable observation>"
```

Step 2 adopts every sidecar line into the pointer. Usually this is a silent skip.

## 2. Route the conversation

```
ORRERY_BUFFER_KEEP_LIVE=1 bash ~/.claude/skills/dissolve/scripts/enqueue-v2.sh full "<one-line session title>"
```

Give a title that will make sense in the dashboard's queue panel (what the session was
about, ≤80 chars). The script appends the pointer `{id, cwd, title, queued_at, source,
mode, highlights}`, adopts and then deletes the sidecar, gzip-copies the transcript into
`~/.orrery/buffer/<date>/`, and — once the queue's pending depth crosses the threshold —
starts a minor reconcile in the background.

`ORRERY_BUFFER_KEEP_LIVE=1` is load-bearing here: the buffer copy is taken while the CLI is
still appending to the live transcript, and removing that file is step 3's job (the kill
archives the final flush, then removes it). Dropping the flag would have the ending race
the CLI for its own transcript.

## 3. Summary, then kill via /delete

State the one-line summary:

> routed for extraction — reconcile extracts and commits from the buffered copy; the live transcript finalizes on exit

Then **invoke the delete skill** (Skill tool, `delete`) with the argument **"already routed
by /dissolve — skip the routing step, kill only"**, in its **default (soft) mode — never
`/delete hard`**: it stops this session's background jobs, finalizes the transcript, and
kills the session. The argument matters — a second routing pass would append a redundant
`salvage` pointer for a conversation that is already queued as `full`. And `--hard` would
erase the buffer copy reconcile is going to read, so a hard dissolve extracts nothing. Do
not call its script directly; the kill lives in one place.

**Human checkpoint**: none. Invoking `/dissolve` IS the go-ahead for routing and kill.

## Notes

- **Pointer outcomes** (reconcile's ledger, `.sweep.jsonl`): `dissolved` (extracted and
  routed) and `trivial` (too little to extract — buffer entry erased) are permanent;
  `waiting` (no buffer copy yet), `deferred` (past the run's spend budget) and `error`
  leave the pointer pending and retry next pass. A pointer still pending after 3 days is
  flagged `questionable` on the board; it is never deleted while its buffer copy exists.
- **Highlights vs. extraction**: highlights are a hint, not a quota and not a lowered bar —
  the extractor still judges everything, including material you never noted.
- **Recoverability**: the gzip in `~/.orrery/buffer/<date>/` is the recoverable copy for 90
  days (`gunzip` it back into `~/.claude/projects/<project>/` to make the conversation
  resumable again). Reconcile never prunes an entry whose pointer is unextracted.
- **`/dissolve` always kills the session** — no extract-only mode. To end without full
  extraction use `/delete` (salvage-only triage); to erase, `/delete hard`. To route an
  already-dead conversation, use the dashboard's picker.
- **Forcing a pass**: `bash ~/.claude/skills/dissolve/scripts/reconcile-kick.sh` re-checks
  the queue depth and starts a minor reconcile if it is at the threshold
  (`ORRERY_KICK_DRYRUN=1` prints the decision without running anything).
- **The built-in verbs route themselves**: hooks in this skill's `hooks/` handle
  `/clear` (routes the cleared context as `full`) and manual `/compact` (a one-shot gate,
  then a pre-compact snapshot). `/exit` deliberately routes nothing.
