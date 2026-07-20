---
paths:
  - "**/*.{ex,exs}"
---

# Elixir

Comment syntax: see `rules/comments.md`.

## Module layout

- **Interleave publics and privates — a helper lives near the function-family it serves; never blanket-segregate every `defp` to the file bottom.** Place a helper after its caller's whole clause group (splitting a multi-clause group draws the grouped-clauses compiler warning); helpers shared across families cluster wherever that family reads best. (since 2026-07-19 · orrery lib/orrery/routines.ex parse_cron call-tree; grove apps/grove/lib/grove/roots/watcher.ex)
- **A wrap-only function delegates to a same-named `do_<name>` private.** When a function only adds setup/teardown — tmp-file lifecycle, telemetry span, `after` cleanup — around the real logic, the logic lives in `do_<name>`. (since 2026-07-19 · orrery lib/orrery/claude.ex run/do_run; grove apps/grove/lib/grove/roots/watcher.ex adopt/do_adopt)
