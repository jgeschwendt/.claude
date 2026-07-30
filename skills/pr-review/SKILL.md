---
name: pr-review
description: >
  Standing reviewer for a GitHub PR — every PR gets one durable review conversation, keyed
  to it and resumed for life. Round 1 seeds a persisted headless `claude` session with the
  whole PR and produces a numbered review; every later round resumes that same session with
  only the delta since the last reviewed head plus current thread state, and the reviewer
  re-judges each of its own prior findings (addressed / stands / obsolete) before reviewing
  what is new. One model call per round, zero when the head SHA has not moved. Reviews land
  as markdown on disk and post to the PR on request. Triggers on "/pr-review", "review PR
  #123", "review this PR", "re-review the PR", "run another review round", "what did the
  reviewer say last time".
allowed-tools: Bash(bash:*), Bash(gh:*), Read, Grep
when_to_use: >
  Use when a PR will be reviewed MORE THAN ONCE — an open PR you are iterating on, a
  long-lived branch, anything you expect to push to and re-review. The built-in `/review` is
  one-shot and stateless: it re-derives its opinion from scratch every time, so round 3
  cannot tell you whether round 1's objection was ever answered. This skill keeps a standing
  conversation per PR, so each round builds on the last and findings carry stable ids across
  the PR's whole life. For a single throwaway look at someone else's PR, `/review` is
  cheaper and correct.
---

# pr-review — the standing reviewer

## The loop

1. **Resolve the ref.** A URL, `OWNER/REPO#N`, `OWNER/REPO N`, `#N`, or a bare `N` (resolved
   against the repo the session is standing in). Ask only if none of those is available.
2. **Run one round:**

   ```
   bash ~/.claude/skills/pr-review/scripts/review.sh <ref>
   ```

   stdout is the review body; progress and the summary line go to stderr.

3. **Present the result** — verdict first (`approve` · `comment` · `request_changes`), then the finding deltas grouped by status, each ordered by severity (`blocker` · `major` · `minor` · `nit`):
   **addressed** (what the last push fixed) · **stands** (still open) · **obsolete** (subject
   gone) · **new** (this round's). Then offer `--post`; never pass it unprompted.

**The session model never reviews the diff itself.** The script's pinned call does —
CLAUDE.md's premium-models-plan-and-review rule applied to judgement work. The reviewer is
`PR_REVIEW_MODEL`; this session relays its output, answers questions about it, and helps
decide what to act on. Reading the diff yourself to second-guess a finding defeats the
standing conversation, which is the only thing that knows what round 1 said.

## State

```
${PR_REVIEW_ROOT:-~/.orrery/reviews}/
└── <owner>-<repo>-<number>/
    ├── state.json      # cache — the ledger tail: {pr, url, cwd, session_id, last_head, round, created, updated}
    ├── ledger.jsonl    # journal — append-only, one line per round: {at, round, head, base, session_id, verdict, findings}
    └── round-<n>.md    # residue — the full review body of round n, the durable artifact
```

Machine-local data, deliberately outside `~/.claude`: reviews are observations about one
machine's checkouts, not portable configuration. Delete a PR's directory to retire its
conversation; the next run seeds a fresh one.

## Atlas lineage

The design is orrery's memory system, applied to a PR instead of a Claude Code session —
orrery `lib/orrery/memory.md` (prose) and `docs/memory-atlas.html` (the same mechanics as
plates). The design inherits these shapes wholesale:

- **Append-only journal, derived state.** `ledger.jsonl` is the truth; `state.json` is
  rebuildable from the ledger and never authoritative — exactly the pointer queue's
  relationship to `.sweep.jsonl`.
- **Durable residue as markdown.** The transcript is not the artifact. `round-<n>.md` is,
  the way committed memories and day pages are the residue of conversations nobody keeps.
- **One hermetic, memory-blind call per round.** `CLAUDE_MEMORY_PIPELINE=1` and
  `--setting-sources ''`, so a review neither reads the user's memory banks nor feeds them,
  and it never inherits the session's model or settings.
  (unverified 2026-07-30 · not probed this run)
- **A no-op costs zero calls.** Nothing extracts a conversation nobody ended; nothing
  reviews a head nobody moved. The unchanged-SHA guard fires before the diff is even
  fetched.

(since 2026-07-28 · orrery lib/orrery/memory.md)

## Env overrides

| Variable                | Default             | Effect                                                                                                          |
| ----------------------- | ------------------- | --------------------------------------------------------------------------------------------------------------- |
| `PR_REVIEW_ROOT`        | `~/.orrery/reviews` | state root — repoint it to sandbox a run                                                                        |
| `PR_REVIEW_MODEL`       | `opus`              | the reviewer model                                                                                              |
| `PR_REVIEW_DRY`         | `0`                 | `1` prints the round, session flag, delta source, cwd and full prompt to stdout, then exits — no call, no state |
| `PR_REVIEW_DIFF_CAP`    | `50000`             | diff chars; over the cap keeps head and tail halves                                                             |
| `PR_REVIEW_THREADS_CAP` | `20000`             | review-thread JSON chars; over the cap keeps the head                                                           |

`PR_REVIEW_DRY=1` is the way to inspect what a round would ask before spending the call.

## Edges

- **Force-push.** The `LAST...HEAD` compare comes back `diverged` (or fails outright), so
  the round falls back to the full diff and the prompt states that the comparison base was
  rewritten — prior findings get re-judged against the whole PR rather than a delta.
- **Merged or closed PRs stay reviewable.** The script warns on stderr and continues; the
  findings apply to a landed diff.
- **`--force`** re-runs a round on an unchanged head. The delta is then empty by
  construction, so the round is a pure re-judgement of the standing findings — useful after
  a thread conversation, wasteful otherwise.
- **The conversation is pinned to a directory.** Session resume is project-dir-keyed, so
  every round runs from the `cwd` stored in round 1. Move or delete that checkout and the
  round refuses rather than silently seeding a second conversation for the same PR.
  (unverified 2026-07-30 · not probed this run)
- **Thread state degrades, it does not vanish.** If `monitor-github`'s
  `scripts/pr_review_threads.sh` is missing or fails, the round proceeds with empty thread
  state and tells the reviewer that state is _unknown_, not _empty_.
