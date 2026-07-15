---
paths:
  - "**/*.md"
---

# Documentation

## Stale-claim custody

Why: every review is diff-scoped and every consistency check uses the repo as its oracle, so a false claim about the *outside world* that predates the diff has neither a reviewer nor an oracle — it survives every edit until someone owns the whole file. (since 2026-07-15 · monitor-github/references/monitoring-guide.md claimed "Claude Code has no dedicated monitor tool" for months while SKILL.md recommended that very tool.)

- **Editing a doc means owning the whole file, not the diff.** Before finishing any edit to a doc, re-read the full file and check its claims about external systems (harness features, tool capabilities, CLI flags, API surfaces) — the repo cannot vouch for these; verify against the live system or current vendor docs, or flag what you couldn't check.
- **Negative capability claims are presumed stale.** "X has no Y", "X can't", "the only way is" — platforms grow, so these rot by default. Re-verify before letting one stand; never write a new one without a live probe.
- **Verification markers carry a date.** Write `(verified 2026-07-15)`, never "verified against current docs" — undated markers inflate trust while rotting invisibly. An undated or old-dated marker is itself a finding.
- **Delegated doc edits inherit this rule explicitly.** A subagent briefed with "surgical edits only" will exempt untouched paragraphs by construction — include whole-file claim custody in the brief, and never scope its consistency check to repo-internal sources alone.
