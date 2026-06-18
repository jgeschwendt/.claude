---
paths:
  - "**/*.{jsx,tsx}"
---

# React

- **Prefer `cond && <X />` over `cond ? <X /> : undefined` for conditional JSX rendering.** Ternaries are only justified when both branches render real elements (`cond ? <A /> : <B />`). If one branch is `undefined` / `null` / `false`, short-circuit with `&&` (or `!cond && <X />` to invert).
