---
paths:
  - "**/*.{bash,sh}"
  - "**/*.{cjs,cts,js,jsx,mjs,mts,ts,tsx}"
  - "**/*.{ex,exs}"
  - "**/*.rs"
---

# Comments

One convention, all languages — only the leader varies: `#` (bash, elixir) · `//` (javascript, rust, typescript).

## Annotations

The `✻` sigil marks in-code notes surfaced during a code scan.

- **`grep` for the `✻` sigil before modifying a file in these languages** — the notes carry context a scan already found and your edit is about to overwrite.
- **Keep an annotation a plain line comment** — never inside a doc comment (`/** */`, `///`, `@doc`, `@moduledoc`).
- **Update or remove a note the moment its subject changes** — a stale `✻` misdirects the next reader.
- **One line per note; use the sigil sparingly.**
- **Wrap at 120 chars, aligning continuation lines under the note text.**

```bash
# ✻ single-line note

# ✻ line 1
#   line 2
```

```typescript
// ✻ single-line note

// ✻ line 1
//   line 2
```

Why: a `✻` note is a message from a scan that already ran; grepping first is how the next editor receives it before touching the code.

## Headers

- **Cap a section divider at 80 columns total; use dividers sparingly.**

```bash
# ─── section title ────────────────────────────────────────────────────────────
```

```typescript
// ─── section title ───────────────────────────────────────────────────────────
```
