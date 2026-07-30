---
name: end-session
description: End the current session and route the conversation for triage extraction — a queue pointer plus a gzip copy in the 90-day buffer, which orrery's reconcile pass then judges and extracts from. Hook-aware — where the SessionEnd router is wired the ending routes itself and this verb only triggers the ending; on a hookless config it enqueues the pointer first. Zero claude calls. Triggers on "/end-session", "end the session", "end this session", "wrap up and exit".
---

# End Session → routed for triage

The SessionEnd router does the routing when it is wired; this verb records anything still
unwritten and then triggers the ending the current config actually supports.

## 1. Note anything the extractor must not miss

Extraction reads the whole conversation, so nothing needs summarizing. But a durable
observation that is in neither an artifact nor this session's pending sidecar gets one line
each — usually a silent skip, since notes are written at the time of attention, not here.

```
~/.orrery/bin/orrery attend "<one durable observation>"
```

## 2. End it

Is the router wired?

```
rg -q 'orrery.* route' ~/.claude/settings.json
```

**Wired, interactive session** — tell the user to type `/exit`. It routes now: the hook
mints the pointer and the buffer copy on the way out, and the sidecar rides along.

**Wired, background agent** — this session appears with `"kind": "background"` in
`claude agents --json`; stop it by its job id — the entry's `id` field, also the basename
of `$CLAUDE_JOB_DIR`. The session id is not accepted (verified 2026-07-30 · `claude stop`
probe: session-id prefix rejected "No job matching", job id accepted):

```
claude stop <job-id>
```

Stopping does not remove the entry from `claude agents` — it stays listed under
Completed, conversation kept, resumable via `claude attach <id>`. Still-resumable
does not mean un-routed: SessionEnd minted the pointer and buffer copy at stop, so
removing the entry — the agents view's ctrl+x ×2 (`deleteJob`) — loses nothing but
the job dir and its `tmp/` scratch. The CLI has no removal verb; when the user wants
the entry gone, schedule a detached reaper before stopping (wait for this session's
pid to die, then `rm -rf` its `$CLAUDE_JOB_DIR`), which replicates `deleteJob`.
Wanting the conversation erased instead of routed is `/delete hard`, not this verb.
(verified 2026-07-30 · `claude stop --help` and binary strings)

**Not wired** (a hookless config — e.g. the work machine) — route the conversation by hand
first, then take the same ending action as above:

```
~/.orrery/bin/orrery enqueue "<one-line session title>"
```

The pointer records `source: end_session`; give a title that will still make sense in the
dashboard's queue panel (what the session was about, ≤80 chars).
