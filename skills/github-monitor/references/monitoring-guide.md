# github-monitor: the daemon & push delivery, explained

How continuous monitoring works in this skill: a background daemon turns
GitHub changes into events, conversations subscribe as _sessions_ with a
repo scope, and a Claude Code hook injects pending events into the
conversation with every message you send — so notifications just show up.

## The routing rule (the contract)

1. A conversation attached from **inside a repo clone** is scoped to that
   repo and receives **only that repo's** notifications.
2. A conversation attached **anywhere else** is global and receives every
   notification **except** those for repos currently claimed by a live
   repo-scoped session.
3. Claims release when a scoped session **detaches** or **expires** (2 hours
   without polling) — a dead conversation can never silently hold a repo's
   notifications hostage.

So: open Claude Code in `~/code/acme-api` and that conversation owns
`acme/api` news; open another conversation from your home directory and it
picks up everything else, with zero configuration. Two sessions scoped to
the same repo both receive its events. Events with no repo (like the
startup notice) go to everyone at baseline, otherwise to global sessions.

## Architecture

```
daemon (monitor.sh _daemon)
  │  every 120s
  ▼
gh_dashboard.sh ──▶ GitHub GraphQL (2 calls)
  │  snapshot json
  ▼
diff_events.jq  (old state.json vs new)
  │  events [{ts, repo, type,
  │           severity, title, url}]
  ▼
route by scope claims
  ▼
queues/<session>.jsonl   (one per conversation)
  ▲
  │  drained by
hook_poll.sh (each prompt)  or  monitor.sh poll <id>
```

Everything is plain files under `~/.local/state/github-monitor`
(override with `GITHUB_MONITOR_DIR`): `daemon.pid`, `daemon.log`,
`state.json` (last snapshot), `sessions/`, `queues/`, and `cc-map/`
(Claude Code session → monitor session). Writes are atomic — queue drains
use `mv`, state saves use temp-then-rename — so a crash loses at most one
tick and can't corrupt anything. The daemon reuses `gh_dashboard.sh` as its
only collector, so snapshot mode and monitoring can never disagree about
what the data means.

## Events

| Type                                                          | Severity    | Fires when                                                                       |
| ------------------------------------------------------------- | ----------- | -------------------------------------------------------------------------------- |
| `review_requested`                                            | high        | A PR newly asks for your review (author and draft status noted)                  |
| `new_review_comments`                                         | high        | Unresolved threads awaiting _your_ reply increased (delta included)              |
| `ci_failed` / `ci_green`                                      | high / info | The check rollup on your PR flipped to failing / recovered                       |
| `changes_requested` / `approved`                              | high        | Review decision on your PR changed                                               |
| `merge_conflict`                                              | high        | Your PR became `CONFLICTING` with its base                                       |
| `pr_merged` / `pr_closed`                                     | high        | Your PR left the open set — one extra lookup distinguishes merged 🎉 from closed |
| `issue_assigned`                                              | high        | An issue was assigned to you                                                     |
| `review_request_cleared`, `own_pr_tracked`, `monitor_started` | info        | Bookkeeping                                                                      |

The first-ever tick captures a baseline silently and sends a single
"monitoring started" notice — no spam about things that were already true.

## Push delivery: three channels

In-session, the preferred channel is the harness's **Monitor tool** wrapped
around `monitor.sh poll` (see SKILL.md) — push delivery with zero config, no
hook install. The hook below is the always-on alternative that covers every
future session; plain `poll` is the manual fallback.

## Push delivery: how the Claude Code hook works

Claude Code has no dedicated monitor tool, but its **hooks** provide the
delivery channel (verified against current docs):

- Hooks are shell commands that fire at lifecycle events and receive JSON
  (`session_id`, `cwd`, `prompt`, …) on stdin.
- On **UserPromptSubmit** and **SessionStart**, whatever the hook prints to
  stdout is injected as context Claude sees — that's the push mechanism.
- Exit code **2** from UserPromptSubmit _blocks your prompt_, so
  `hook_poll.sh` is engineered to always exit 0 and to print nothing at all
  when there's no news.
- Hook config is snapshotted at session start (review with `/hooks`), so it
  applies from your next session. Hook output is capped at 10k characters;
  the adapter prints at most 30 events and tells Claude how to get the rest.

Per message, the flow is: hook fires → reads `session_id` + `cwd` → **first
time only:** attaches a monitor session (scope auto-detected from the cwd
via `gh repo view`, falling back to parsing the `origin` remote), records
the mapping in `cc-map/`, and announces the scope → **every time:** drains
this conversation's queue and prints events as bullet lines with severity
and URL. Polling doubles as the heartbeat that keeps the repo claim alive;
go quiet for 2h and the session expires. Wiring the same script into
**SessionEnd** (included in the generated config) detaches instantly
instead of waiting for the TTL.

## Setup

```bash
bash ~/.claude/skills/github-monitor/scripts/monitor.sh hook-config
# merge the printed snippet into ~/.claude/settings.json, check /hooks,
# then start a new session
```

Requires `gh` (authenticated) and `jq`. GitHub Enterprise works via
`GH_HOST` (the daemon inherits it at start). Without the hook, everything
still works pull-style: Claude runs `poll` when you ask "anything new?".

## Command reference

| Command                                      | Does                                                                   |
| -------------------------------------------- | ---------------------------------------------------------------------- |
| `monitor.sh attach [--repo o/r \| --global]` | Register a session (auto-scopes from cwd); starts the daemon if needed |
| `monitor.sh poll <id>`                       | Drain pending events (JSONL; empty = no news; heartbeats the claim)    |
| `monitor.sh detach <id>`                     | Unregister and release the repo claim                                  |
| `monitor.sh status`                          | Daemon pid + interval + sessions, scopes, queue depths                 |
| `monitor.sh start [--interval N]` / `stop`   | Daemon lifecycle (stop keeps sessions)                                 |
| `monitor.sh tick`                            | One foreground poll cycle (debugging)                                  |
| `monitor.sh hook-config`                     | Print the settings.json snippet for push delivery                      |

## Cost & limits

A tick is 2 GraphQL calls (~1 rate-limit point each) plus one cheap lookup
per merged/closed PR. At the default 120s interval that's ~720 light calls
a day against a 5,000-point/hour GraphQL budget — negligible. Sections cap
at 50 items per query and thread stats cover the first 50 threads per PR;
the drill-down script paginates when you need complete depth on one PR.

## What's been tested (and what hasn't)

Tested end-to-end against simulated GitHub responses: the full routing
contract (scoped-only delivery, global exclusion of claimed repos, claim
release on detach), the hook lifecycle (attach announcement, baseline
notice, event injection, silence when quiet, SessionEnd cleanup), remote
parsing for ssh and https origins, all argument forms, and atomic queue
drains. Not yet exercised: real GitHub traffic — the first live run on your
account is the remaining validation, and `monitor.sh tick` + `daemon.log`
are the debugging tools if anything surprises.
