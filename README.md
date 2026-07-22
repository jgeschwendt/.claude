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
