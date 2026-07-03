---
paths:
  - "**/.oxfmtrc*"
  - "**/eslint.config.*"
  - "**/oxfmt.config.*"
  - "**/rustfmt.toml"
---

# Rules — harvest queue

This rule loads when a formatter/linter config enters context. When the config encodes a standard that is judgment-bearing (not pure style — style is auto-formatted), a tool default (the default IS the universality evidence — verified against the tool's docs/source at drain), and absent from `rules/`, append it below as one line. A repo's bespoke override is never global — encode it into that repo's `.claude/` at capture time (Golden Rule) instead of queueing. Capture only — never edit `rules/*.md` mid-task. Promotion is automatic: `/dissolve` drains this queue at session end.

Entry — the drain reads only the lines below the marker:
`- [ ] (YYYY-MM-DD · <repo> · <tool:rule>) → rules/<lang>.md: <standard — one-phrase why>`

<!-- captures below -->
