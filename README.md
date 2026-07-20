# ~/.claude

The versioned home of Claude Code, synced across machines: the config that shapes every session, plus the machine-local data those sessions accrete.

## Tracked

- `CLAUDE.md` — global instructions: the Golden Rule, house rules, memory contract
- `rules/` — house coding standards, referenced from CLAUDE.md
- `skills/` — personal skills (lean, self-contained; the work fleet lives elsewhere)
- `hooks/` — `memory-recall` (SessionStart bank injection), `format`, `drain`
- `commands/refine/` — `/refine:code|documentation|prompt`
- `settings.json`, `statusline.js`, `themes/` — harness config
- `save` — the daily save: amend today's commit if it exists, else a fresh `update: MM/DD/YY`, then force-push main

## Data (gitignored, machine-local)

Overlay directories use an `@` prefix to stay clear of Claude Code's own namespace:

- `@memory/` — committed memory banks + `.staging.json` inbox
- `@log/` — day-by-day user log
- `@routines/` — launchd routine scripts, prompts, last-run results
- `@research/`, `@feedback/` — research output, cross-agent feedback inbox
- `projects/`, `plans/`, … — Claude Code's own transcripts and state

## The app

The Phoenix app that runs the memory pipeline and serves dashboards over this
data lives at [`jgeschwendt/orrery`](https://github.com/jgeschwendt/orrery);
see its README for setup, the data contract, and how a machine wires it up.
