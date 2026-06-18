---
paths:
  - "**/.oxfmtrc*"
  - "**/eslint.config.*"
  - "**/oxfmt.config.*"
  - "**/rustfmt.toml"
---

# Rules — harvest queue

This rule loads when a formatter/linter config enters context. When the config encodes a standard that is judgment-bearing (not pure style — style is auto-formatted), universal (a tool default, or seen in ≥2 distinct repos — never one repo's bespoke rule), and absent from `rules/`, append it below as one line. Capture only — never edit `rules/*.md` mid-task; repo-specific standards stay in that repo's `.claude/`. Promote / prune: `/learn`.

Entry — `/learn` reads only the lines below the marker:
`- [ ] (YYYY-MM-DD · <repo> · <tool:rule>) → rules/<lang>.md: <standard — one-phrase why>`

<!-- captures below -->
