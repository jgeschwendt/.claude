---
name: submit
argument-hint: "[--draft]"
description: "Open a PR for the current branch and drive it to green — preflight, create, watch CI, fix fixable failures, surface review. Self-contained (git + gh). Usage: /submit [--draft]"
disable-model-invocation: true
when_to_use: "Use when a feature branch is ready to become a PR and should be driven to 'ready for review' hands-off. Examples: 'submit the pr', 'open a pr and get it green', 'ship this branch', 'submit as draft'."
---

# Submit

Open a PR for the current branch, then watch CI and drive it to green — fixing the failures that are this branch's fault, skipping the ones that aren't, and surfacing review feedback. Self-contained: only `git` and `gh`, no sibling skills.

Only two interactive pauses by design: the dirty-tree decision (step 1) and review handling (step 7). Everything else runs straight through.

## Inputs

- `$ARGUMENTS` — optional `--draft` to open a draft PR (skips step 7 review handling).

## Goal

A PR open on the current branch with all _required_ checks green (advisory / pre-existing failures called out, not chased) and review feedback addressed or replied to — reached without hand-holding.

## Steps

### 1. Preflight

```bash
base=$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name)
branch=$(git symbolic-ref --short -q HEAD) || { echo "refuse: detached HEAD"; exit 1; }
[[ "$branch" != "$base" ]] || { echo "refuse: on $base — submit runs on a feature branch"; exit 1; }
git status --short && git log --oneline "$base..HEAD" && git diff --stat "$base...HEAD"
```

Refuse on the default branch — a PR submits a _branch_, never the trunk. If the tree is dirty:

- **Commits already ahead of base** → amend the latest with the staged+unstaged changes (`git commit --amend --no-edit` after staging the specific changed files by name — never `git add -A`).
- **No commits ahead** → create a new commit; derive the message from the diff.

**Success:** on a feature branch, working tree clean, ≥1 commit ahead of `$base`.

### 2. Push

```bash
git push -u origin HEAD          # first push
git push --force-with-lease      # after an amend
```

**Success:** `origin/$branch` matches local HEAD.

### 3. Compose title + body

Title: < 70 chars, imperative. Body from `git log "$base..HEAD"` + the diff:

```markdown
## Changes

<what changed and why>

## Test Plan

- [ ] <inferred from the diff>
```

Add a `## Decisions` table only when there's a non-obvious architectural choice worth recording. Keep `{pr_number}` as a placeholder for any self-referential link — patched in step 5.

### 4. Create PR

```bash
gh pr create --title "<title>" --body "<body>" $([[ "$ARGUMENTS" == *--draft* ]] && echo --draft)
```

**Success:** command returns a PR URL.

### 5. Print URL & patch placeholders

Print the URL first so the user has a link while CI runs. If the body used `{pr_number}`, fetch the number and `gh pr edit <n> --body "<patched>"`.

### 6. Watch CI & fix

Poll in the background so the turn ends and CI completion re-invokes you (do not block a tool call on a multi-minute run, and do not foreground-`sleep`):

```bash
gh pr checks <n> --watch --interval 30 --fail-fast    # run_in_background: true
```

When it returns, read results and classify each failed check:

| Class            | Action                                                                                                                     |
| ---------------- | -------------------------------------------------------------------------------------------------------------------------- |
| **Fixable**      | Required check failing on this branch's code (lint, format, types, test, build) → fix locally, amend, force-push, re-watch |
| **Advisory**     | Non-required scanner (codeql, sonar, snyk, bot review) → skip unless it surfaces a real bug                                |
| **Pre-existing** | Same failure exists on `$base` → skip                                                                                      |
| **Unfixable**    | Infra / runner / external outage → spot-check, then skip                                                                   |

If the repo has no checks configured, skip to step 7. After each fix-push, **re-sync title/body** (step 3) — the diff changed, so the description may no longer match. This is the step that's almost always missed; treat it as part of the push, not a follow-up.

**Auto-learn:** used a fix pattern or check class not in the table? Append it to `LEARNINGS.md` (→ ## Learning) the moment you apply it — don't defer to end-of-run.

**Success:** every required check is green (or the only reds are Advisory / Pre-existing, each named in the summary).

### 7. Review (skip if `--draft`)

```bash
gh pr view <n> --json reviewDecision,reviews,comments,latestReviews
```

Surface human review feedback as a short table (file:line · ask · proposed action). For each: fix → amend → force-push → re-sync (step 3 + 6), or reply with a one-paragraph rationale citing the load-bearing constraint. Reply to human threads; never resolve them — the reviewer does that.

**Auto-learn:** a review move not covered here → append it to `LEARNINGS.md` as you make it.

**Success:** every requested change is addressed or has a reasoned reply; `reviewDecision` is `APPROVED` or the only block is `REVIEW_REQUIRED` (the human gate).

### 8. Summary

```
PR #<n> — submitted
CI:     [x] required green (<rounds> rounds, <sha1>→<shaN>)   [ ] <k> advisory/pre-existing (<names>)
Review: [x] <m> threads replied (awaiting reviewer)            [ ] <k> pending human decision
Status: Ready for review ✓   (or  Draft  /  Blocked: <reason>)
<url>
```

If `--draft`, omit the Review line and read status `Draft`.

## Learning

Capture is continuous — not a closing step. The moment a run goes off the documented playbook, append one line to `${CLAUDE_SKILL_DIR}/LEARNINGS.md`, backed by a concrete artifact (PR #, SHA, check name, reviewer handle). No end-of-run review ritual: if nothing went off-playbook, nothing is captured — so there's no "did I remember to reflect?" honesty gap to guard.

Triggers — capture the moment you notice: a CI fix pattern or check class not in step 6 · a review move not in step 7 · a step that was wrong or out of order · an uncovered edge case.

`- [ ] (YYYY-MM-DD · <artifact>) → <dest>: <one-line change>`

`<dest>`: **this SKILL.md** (a general defect in these steps) · **the repo** (a repo-specific fact → that repo's `.claude/`) · **user memory** (your personal style).

- **Capture always** — inline, even in an unattended run; it never blocks the loop.
- **Net-zero** — overlaps an existing trigger or table row → merge into that line, don't add.
- **Promote (interactive runs)** — at the start of an interactive `/submit`, drain pending entries: re-verify each still holds (present? contradiction? genuinely general, not repo-specific in disguise?), apply to its `<dest>` stamped `(since <date> · <artifact>)`, then check it off. An entry that recurs 3× promotes as a blocking edit.

## Rules

- **Never force-push the default branch**, and never `git add -A` / `git add .` — stage changed files by name (avoids sweeping in unrelated or sensitive files).
- **Amend, don't stack**, while iterating on an open PR — one clean commit per logical change; `--force-with-lease` protects against clobbering an unseen remote advance.
- **Re-sync the PR title/body after every amend+push** (steps 6–7). The diff moved; the description must follow.
- Silence on success: don't narrate the wait. End the turn after launching the background watch; act when the completion notification arrives.
- Chase only what's yours: a red check that fails identically on `$base`, or a non-required scanner, is not this PR's job — name it and move on.
