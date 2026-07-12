---
paths:
  - "**/*.{bash,sh}"
---

# Bash

## Compatibility

- Target macOS `/bin/bash` 3.2: never put `case` inside `$( )` command substitution—the 3.2 parser fails on the pattern's `)`. Hoist the block into a function and call it inside the substitution. (since 2026-07-12 · github-monitor/scripts/monitor.sh)

## Comments

### Annotations

Rules:

- `grep` for `# ✻` before modifying a file.
- Update or remove stale notes.
- Use sparingly—one line per note.
- Wrap at 120 chars.

```bash
# ✻ single-line note

# ✻ line 1
#   line 2
```

### Headers

Total divider width: 80 columns—use sparingly

```bash
# ─── section title ────────────────────────────────────────────────────────────
```
