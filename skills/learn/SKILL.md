---
name: learn
allowed-tools:
  - AskUserQuestion
  - Bash
  - Edit
  - Glob
  - Grep
  - Read
  - Write
argument-hint: "[skill name or lang — optional, e.g. craft-prompt or typescript]"
description: Drain the harvest queues — promote captured coding standards (rules/auto-learn.md → rules/*.md) and skill self-improvement learnings (skills/*/LEARNINGS.md → that skill's files / repo / memory); prune what tooling or source contradicts.
disable-model-invocation: true
when_to_use: "Use to drain the learning queues: promote captured coding standards into rules/*.md, drain a skill's LEARNINGS.md into its SKILL.md / reference files / user memory, or prune a rule that repo tooling contradicts. Trigger phrases: '/learn', 'promote the learnings', 'drain the rules queue', 'drain the learnings', 'graduate harvested rules'."
---

# Learn — promote harvested learnings into their durable homes

Two append-only capture queues feed this skill; both are drained here, never mid-task:

- **Coding standards** — `~/.claude/rules/auto-learn.md`, harvested when a formatter/linter config enters context → promote into `~/.claude/rules/<lang>.md`.
- **Skill self-improvement** — `~/.claude/skills/<skill>/LEARNINGS.md`, captured the moment a skill run goes off its playbook → promote into that skill's `SKILL.md` (or its reference files), the relevant repo's `.claude/`, or user memory.

Capture happens elsewhere; `/learn` only promotes and prunes. If `$ARGUMENTS` names a language (`typescript`), consider only that rules file; if it names a skill (`craft-prompt`), drain only that skill's queue; if empty, drain everything pending.

## Steps

### 1. Load

Read every unchecked entry below the `<!-- captures below -->` marker in:

- `~/.claude/rules/auto-learn.md` (coding standards), plus the existing `~/.claude/rules/<lang>.md` files for context (not `auto-learn.md` itself).
- each `~/.claude/skills/*/LEARNINGS.md` (skill learnings), plus the target skill's `SKILL.md` and any reference files an entry routes to.

Scope by `$ARGUMENTS` if given. If nothing is pending, report `queue empty` and stop.

### 2. Verify each candidate against its bar

Promote only if it clears the bar for its queue — otherwise leave it queued, or strike it with a one-line reason so it won't resurface.

**Coding standards** — all must hold:

- **Tool-encoded** — names the config + rule it came from.
- **Universal** — a tool default, or recorded from ≥2 distinct repos. One repo's bespoke rule → reject; it belongs in that repo's `.claude/`.
- **Judgment-bearing** — not pure style already delegated to auto-formatting (CLAUDE.md).
- **Net-zero** — overlaps an existing rule → merge/refine, don't add a line.
- **Statable** — expressible as a house-style line: rule first, one-phrase rationale.

**Skill learnings** — all must hold:

- **Still holds** — re-check against current source/behavior; a learning the skill has already moved past is struck, not promoted.
- **General, not disguised-specific** — a real defect in the skill's teaching or workflow, not a one-off it could not have prevented. Repo-specific facts route to that repo's `.claude/`; the user's personal style routes to user memory — neither is a skill edit.
- **Net-zero** — overlaps an existing catalog entry or checklist line → merge into it, don't add.
- **Destination-correct** — the entry's routed `<dest>` is where the fix actually belongs (e.g. a missing technique → `TECHNIQUES.md`, a misrouting → `SKILL.md`).

### 3. Promote

For each survivor, Edit the routed destination in house style, stamped `(since <date> · <artifact-or-tool:rule> [×N repos])`; show each edit as a diff. Create a missing `rules/<lang>.md` by mirroring `rules/typescript.md` (correct `paths:` frontmatter; `## Comments` Annotations + Headers structure). Route personal-style entries to user memory via the auto-memory system, not a skill edit.

### 4. Prune — the self-healing half

Cross-check existing rules and skill instructions against the candidates and any cited tooling/source: if a current rule or skill instruction is repeatedly _contradicted_ by repo tooling or by the live source, surface it with the contradicting evidence and propose removal/demotion via `AskUserQuestion`. Apply only on confirmation — a rule may be a deliberate override of a tool default.

### 5. Reconcile & report

Check off promoted entries (`- [x]`); keep rejected ones struck with their reason. An entry that has recurred across **3** drains promotes as a blocking edit rather than staying queued — repeat captures mean the target needs to change, not the queue. Report three lists: **promoted** (`<dest>`: change), **rejected** (+ why), **pruned**.

## Rules

- Never promote a single-repo standard into the global rules or a skill's shared files — universal or it stays put.
- These edits touch the user's global rules, skills, and memory — show diffs, don't silently rewrite.
- Alpha-sort and house style per CLAUDE.md; keep each line rule-first with a rationale.
- Don't hunt for new learnings here; promotion drains what was already captured — unless `$ARGUMENTS` asks you to scan a specific repo's tooling or a skill's recent runs first.
