# ~/.claude

What shapes a Claude Code session is tracked and synced; what sessions accrete stays gitignored.

## Tracked

<!-- curated, not exhaustive: hooks/drain.js and plugins/config.json are tracked but deliberately omitted -->

```
~/.claude
├── hooks/
│   └── format.js          PostToolUse formatter
├── rules/                 house standards for code and docs
├── skills/                personal skills, lean and self-contained
├── CLAUDE.md              global instructions: golden rule, house rules, memory contract
├── save                   amend or cut today's sync: MM/DD/YY commit; force-push main
├── settings.json          harness config — hook wiring, permissions
├── settings.local.json    output-style override
└── statusline.js
```
