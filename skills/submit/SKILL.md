---
name: submit
allowed-tools: AskUserQuestion, Bash(cut:*), Bash(echo:*), Bash(gh:*), Bash(git:*), Bash(rg:*), Bash(sleep:*), Edit, Glob, Grep, Read, Write
argument-hint: "[--draft]"
description: "Open a PR for the current branch and drive it to green — preflight, create, watch CI, fix fixable failures, surface review. Self-contained (git + gh). Usage: /submit [--draft]"
disable-model-invocation: true
when_to_use: "Use when a feature branch is ready to become a PR and should be driven to 'ready for review' hands-off. Examples: 'submit the pr', 'open a pr and get it green', 'ship this branch', 'submit as draft'."
---

# Submit

Open a PR for the current branch, then watch CI and drive it to green — fixing the failures that are this branch's fault, skipping the ones that aren't, and surfacing review feedback. Self-contained: only `git` and `gh`, no sibling skills.

Only two interactive pauses by design: the dirty-tree decision (step 1) and review handling (step 7). Everything else runs straight through.

## Inputs

- `$ARGUMENTS` — optional `--draft`, passed to `gh pr create` in step 4. Later steps key off the PR's live `isDraft`, never off `$ARGUMENTS` — a resumed run may adopt a PR whose draft state differs.

## Goal

A PR open on the current branch with all _required_ checks green (advisory / pre-existing failures called out, not chased) and review feedback addressed or replied to — reached without hand-holding.

## Steps

### 1. Preflight

```bash
repo=$(gh repo view --json nameWithOwner -q .nameWithOwner)   # the PR-base repo (errors → gh repo set-default)
base=$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name)
remote=$(git remote -v | rg -im1 "[:/]${repo}(\.git)?[[:space:]]" | cut -f1)   # remote hosting the base repo — origin usually, upstream on forks; anchored so acme/api can't match acme/api-client
remote=${remote:-origin}                                      # …but never assume the name
git fetch -q "$remote" "$base"                                # compare against $remote/$base — the local ref may be stale or absent
branch=$(git symbolic-ref --short -q HEAD) || { echo "refuse: detached HEAD"; exit 1; }
[[ "$branch" != "$base" ]] || { echo "refuse: on $base — submit runs on a feature branch"; exit 1; }
pr=$(gh pr view --json number,state --jq 'select(.state == "OPEN").number' 2>/dev/null)
git status --short && git log --oneline "$remote/$base..HEAD" && git diff --stat "$remote/$base...HEAD"
```

Refuse on the default branch — a PR submits a _branch_, never the trunk. An open PR already on this branch (`$pr` non-empty) → adopt it: handle the dirty tree below, push (step 2), re-sync title/body and print the URL (steps 3 + 5, via `gh pr edit`), then jump to step 6 — re-running /submit resumes, it never errors on its own PR.

If the tree is dirty, this is the first designed pause — silently sweeping uncommitted changes into a PR is how unrelated work ships. AskUserQuestion: **include** them (Recommended), **stash** them out (`git stash push -u`; pop before any exit — step 8 or an early abort — never leave WIP parked), or **abort** (tree untouched). Including: commits already ahead of `$remote/$base` → amend the tip (`git commit --amend --no-edit`); none → new commit, message derived from the diff. Either way stage the changed files by name — never `git add -A`.

**Success:** on a feature branch, working tree clean, ≥1 commit ahead of `$remote/$base`.

### 2. Push

```bash
git push -u origin HEAD          # first push — origin is the remote you have write access to (your fork, when the base repo lives on $remote)
git push --force-with-lease      # after an amend
```

Lease rejected → the remote genuinely advanced (a reviewer committed via the UI, a bot pushed a fixup): fetch, rebase your work onto the remote branch tip, push again — never bare `--force`. No remote named `origin` → push to the branch's existing upstream, else `$remote`.

**Success:** the push remote's `$branch` matches local HEAD.

### 3. Compose title + body

Title: < 70 chars, imperative. Body from `git log "$remote/$base..HEAD"` + the diff:

```markdown
## Changes

<what changed and why>

## Test Plan

- [ ] <inferred from the diff>
```

Add a `## Decisions` table only when there's a non-obvious architectural choice worth recording. Keep `{pr_number}` as a placeholder for any self-referential link — patched in step 5. Write the body to a temp file outside the repo — `--body-file` is quoting-proof for multi-line markdown; inline `--body` isn't.

### 4. Create PR

```bash
gh pr create --title "<title>" --body-file <file>   # append --draft when $ARGUMENTS asks for it
```

**Success:** command returns a PR URL.

### 5. Print URL & patch placeholders

Print the URL first so the user has a link while CI runs. If the body used `{pr_number}`, patch the body file and `gh pr edit <n> --body-file <file>`.

### 6. Watch CI & fix

Poll in the background so the turn ends and CI completion re-invokes you (do not block a tool call on a multi-minute run, and do not foreground-`sleep`):

```bash
gh pr checks <n> --watch --interval 30 --fail-fast    # run_in_background: true
```

If the watch exits immediately claiming no checks, distinguish "not registered yet" from "none configured": retry once via a background `sleep 30 && gh pr checks <n> --watch …` (its exit re-invokes you; foreground sleep is banned) — only a second empty result means skip to step 7.

When it returns, classify each failed check — required-ness is queryable, not guessed (verified 2026-07-15 · gh 2.95.0):

```bash
gh pr checks <n> --json name,bucket,link,workflow   # bucket: pass|fail|pending|skipping|cancel
gh pr checks <n> --required --json name             # the required set; the difference is advisory. Errors "no required checks reported" when protection defines none → treat ALL checks as required
```

| Class            | Action                                                                                                                                |
| ---------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| **Fixable**      | Required check failing on this branch's code (lint, format, types, test, build) → reproduce locally, fix, amend, force-push, re-watch |
| **Advisory**     | Non-required scanner (codeql, sonar, snyk, bot review) → skip unless it surfaces a real bug                                           |
| **Pre-existing** | Same failure exists on `$remote/$base` (spot-check: `gh run list --branch "$base" -L 5`) → skip                                       |
| **Unfixable**    | Infra / runner / external outage → spot-check, then skip                                                                              |

**Never advance on a pending snapshot:** `--fail-fast` exits on the _first_ red — when the reds all classify as skippable but any required check is still `pending`, re-launch the background watch instead of proceeding.

**Bound the loop:** the same check still red after 2 fix rounds → reclassify as Blocked, stop chasing, and name it in the summary with your best diagnosis — a third blind push is churn, not progress.

After each fix-push, **re-sync title/body** (step 3) — the diff changed, so the description may no longer match. This is the step that's almost always missed; treat it as part of the push, not a follow-up.

**Auto-learn:** used a fix pattern or check class not in the table? Encode it into the table the moment you apply it (→ ## Learning) — don't defer to end-of-run.

**Success:** every required check is green (or the only reds are Advisory / Pre-existing, each named in the summary) — or the run ends Blocked per the loop bound, stated in the summary.

### 7. Review (skip while `isDraft`)

```bash
gh pr view <n> --json isDraft,reviewDecision,reviews,comments,latestReviews
gh api --paginate "repos/{owner}/{repo}/pulls/<n>/comments"   # file:line threads — pr view's `comments` is issue-level only; unpaginated REST truncates at 30
```

Surface human review feedback as a short table (file:line · ask · proposed action) — humans only, bots' output was classified in step 6. Fixes run hands-off: fix → amend → force-push → re-sync (steps 3 + 6). Replies post in the user's name — outward-facing, so this is the second designed pause: present the proposed replies and get one AskUserQuestion approval before posting any (a one-paragraph rationale citing the load-bearing constraint). Reply to human threads (`gh api --method POST "repos/{owner}/{repo}/pulls/<n>/comments/<id>/replies" -f body=…`); top-level review remarks have no thread — answer those with `gh pr comment <n>`. Never resolve threads — the reviewer does that.

**Auto-learn:** a review move not covered here → encode it into this step as you make it.

**Success:** every requested change is addressed or has a reasoned reply. An empty `reviewDecision` (no reviews yet), `REVIEW_REQUIRED`, or `CHANGES_REQUESTED` with every thread addressed are all terminal — the reviewer's next move is outside this run; report the state, never wait on it.

### 8. Summary

```
PR #<n> — submitted
CI:     [x] required green (<rounds> rounds, <sha1>→<shaN>)   [ ] <k> advisory/pre-existing (<names>)
Review: [x] <m> threads replied (awaiting reviewer)            [ ] <k> pending human decision
Status: Ready for review ✓   (or  Draft  /  Blocked: <reason>)
<url>
```

If the PR is a draft (`isDraft`), omit the Review line and read status `Draft`. Stashed changes from step 1 → `git stash pop` now, before printing.

## Learning

No capture queue. The moment a run goes off the documented playbook, encode the fix directly into its destination (Golden Rule, CLAUDE.md), backed by a concrete artifact (PR #, SHA, check name, reviewer handle): a general defect in these steps → this SKILL.md · a repo-specific fact → that repo's `.claude/` · the user's personal style → user memory (`/dissolve` at session end). Stamp the edit `(since <date> · <artifact>)`. Net-zero — an overlap with an existing trigger or table row merges into that line, never adds one.

## Rules

- **Never force-push the default branch**, and never `git add -A` / `git add .` — stage changed files by name (avoids sweeping in unrelated or sensitive files).
- **Amend, don't stack**, while iterating on an open PR — one clean commit per logical change; `--force-with-lease` protects against clobbering an unseen remote advance.
- **Re-sync the PR title/body after every amend+push**, whichever step pushed. The diff moved; the description must follow.
- Silence on success: don't narrate the wait. End the turn after launching the background watch; act when the completion notification arrives.
- Chase only what's yours: a red check that fails identically on `$remote/$base`, or a non-required scanner, is not this PR's job — name it and move on.
