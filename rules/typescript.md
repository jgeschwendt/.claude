---
paths:
  - "**/*.{cts,jsx,mts,ts,tsx}"
---

# TypeScript

- **Always inline single-use type aliases.** Before reporting any code-writing turn complete, scan the diff for `type X = {…}` / `interface X {…}` referenced exactly once in the same file → inline into the signature.

  Exception: when the binding name carries meaning the expression doesn't — an inferred type pinned with `type Resolved = ReturnType<typeof f>` so it surfaces in errors, or a structural type whose name documents intent at every use site.

## Comments

### Annotations

Rules:

- `grep` for `// ✻` before modifying a file.
- Always a line comment (`// ✻ …`), never inside `/** */`.
- Update or remove stale notes.
- Use sparingly—one line per note.
- Wrap at 120 chars.

```typescript
// ✻ single-line note

// ✻ line 1
//   line 2
```

### Headers

Total divider width: 80 columns—use sparingly

```typescript
// ─── section title ───────────────────────────────────────────────────────────
```
