#!/usr/bin/env bash
# gh_dashboard.sh — collect the authenticated user's GitHub attention items.
#
# Gathers, in two API calls (~2s) — one GraphQL query + `gh api user`:
#   1. Their open PRs: CI status, review decision, merge conflicts, and
#      unresolved review-thread counts split by who owes the next reply
#      (review-thread resolution state is GraphQL-only — REST and
#      `gh pr view --json` cannot see it, which is why this uses gh api graphql).
#      Also: merge_state (mergeStateStatus), in_merge_queue, auto_merge,
#      base branch, latest_reviews, Conversation-tab comment activity, and a
#      computed ready_to_merge flag.
#   2. Open PRs where their review is requested (oldest-waiting first),
#      including whether the user has an UNSUBMITTED pending review sitting there
#   3. Open issues assigned to them (with up to 5 label names)
#   4. Open Issues and PRs that mention them (last 30 days, not self-authored)
#
# Usage:   gh_dashboard.sh [limit]     # items per section, default 20, max 50
# Output:  one JSON object on stdout (see SKILL.md for field meanings)
# Errors:  {"error": ..., "hint": ...} on stderr, exit 1
#
# Works against GitHub Enterprise too: GH_HOST=github.mycorp.com gh_dashboard.sh

set -euo pipefail

LIMIT="${1:-20}"
if ! [[ "$LIMIT" =~ ^[0-9]+$ ]] || [ "$LIMIT" -lt 1 ] || [ "$LIMIT" -gt 50 ]; then
  echo '{"error":"bad_limit","hint":"limit must be an integer between 1 and 50"}' >&2
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo '{"error":"gh_not_installed","hint":"Install the GitHub CLI: https://cli.github.com"}' >&2
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo '{"error":"not_authenticated","hint":"Run: gh auth login"}' >&2
  exit 1
fi

# Resolve the login explicitly (rather than relying on @me) so the same
# search strings work identically on github.com and Enterprise hosts.
LOGIN="$(gh api user --jq .login)"

# 30-day lower bound for the mentions search (BSD date first, GNU fallback).
SINCE="$(date -u -v-30d +%F 2>/dev/null || date -u -d '30 days ago' +%F)"

QUERY='
query($myq: String!, $revq: String!, $issq: String!, $menq: String!, $limit: Int!) {
  viewer { login }
  myPRs: search(query: $myq, type: ISSUE, first: $limit) {
    issueCount
    nodes {
      ... on PullRequest {
        number title url isDraft reviewDecision mergeable updatedAt
        mergeStateStatus isInMergeQueue baseRefName
        autoMergeRequest { enabledAt }
        repository { nameWithOwner }
        commits(last: 1) { nodes { commit { statusCheckRollup { state } } } }
        reviewRequests(first: 10) {
          nodes { requestedReviewer { ... on User { login } ... on Team { name } } }
        }
        latestReviews(first: 10) { nodes { author { login } state } }
        comments(last: 1) { totalCount nodes { author { login } } }
        reviewThreads(first: 50) {
          nodes {
            isResolved isOutdated
            comments(last: 1) { nodes { author { login } } }
          }
        }
      }
    }
  }
  reviewRequests: search(query: $revq, type: ISSUE, first: $limit) {
    issueCount
    nodes {
      ... on PullRequest {
        number title url isDraft updatedAt additions deletions changedFiles
        author { login }
        repository { nameWithOwner }
        commits(last: 1) { nodes { commit { statusCheckRollup { state } } } }
        reviewThreads(first: 50) { nodes { isResolved } }
        reviews(states: PENDING, first: 5) { nodes { author { login } } }
      }
    }
  }
  assignedIssues: search(query: $issq, type: ISSUE, first: $limit) {
    issueCount
    nodes {
      ... on Issue {
        number title url updatedAt
        labels(first: 5) { nodes { name } }
        repository { nameWithOwner }
      }
    }
  }
  mentions: search(query: $menq, type: ISSUE, first: $limit) {
    issueCount
    nodes {
      __typename
      ... on Issue        { number title url updatedAt author { login } repository { nameWithOwner } }
      ... on PullRequest  { number title url updatedAt author { login } repository { nameWithOwner } }
    }
  }
}'

# sort:updated-asc on review requests = longest-waiting first, so the most
# overdue reviews survive the limit cut.
gh api graphql \
  -f query="$QUERY" \
  -f myq="is:pr is:open author:$LOGIN archived:false sort:updated-desc" \
  -f revq="is:pr is:open review-requested:$LOGIN archived:false sort:updated-asc" \
  -f issq="is:issue is:open assignee:$LOGIN archived:false sort:updated-desc" \
  -f menq="is:open mentions:$LOGIN -author:$LOGIN updated:>=$SINCE sort:updated-desc" \
  -F limit="$LIMIT" \
  --jq '.data.viewer.login as $login | {
    login: $login,
    my_prs: {
      total: .data.myPRs.issueCount,
      items: [.data.myPRs.nodes[]
        | (.isDraft) as $draft
        | (.reviewDecision // "NONE") as $review
        | (.commits.nodes[0].commit.statusCheckRollup.state // "NO_CHECKS") as $ci
        | {
        repo: .repository.nameWithOwner,
        number, title, url,
        draft: $draft,
        review: $review,
        mergeable,
        ci: $ci,
        merge_state: (.mergeStateStatus // "UNKNOWN"),
        in_merge_queue: (.isInMergeQueue // false),
        auto_merge: (.autoMergeRequest != null),
        base: .baseRefName,
        pending_reviewers: [.reviewRequests.nodes[].requestedReviewer | values | (.login // .name)],
        latest_reviews: [.latestReviews.nodes[]? | {author: (.author.login // "ghost"), state}],
        conversation: {
          total: (.comments.totalCount // 0),
          last_author: (.comments.nodes[0].author.login // null)
        },
        review_comments: (
          [.reviewThreads.nodes[]? | select(.isResolved | not)] as $u | {
            unresolved: ($u | length),
            needs_your_reply: ([$u[] | select((.comments.nodes[0].author.login // "") != $login)] | length),
            waiting_on_reviewer: ([$u[] | select((.comments.nodes[0].author.login // "") == $login)] | length),
            outdated: ([$u[] | select(.isOutdated)] | length)
          }
        ),
        ready_to_merge: (($draft | not) and $review == "APPROVED"
          and ($ci == "SUCCESS" or $ci == "NO_CHECKS") and .mergeable == "MERGEABLE"),
        updatedAt
      }]
    },
    review_requests: {
      total: .data.reviewRequests.issueCount,
      items: [.data.reviewRequests.nodes[] | {
        repo: .repository.nameWithOwner,
        number, title, url,
        draft: .isDraft,
        author: (.author.login // "ghost"),
        ci: (.commits.nodes[0].commit.statusCheckRollup.state // "NO_CHECKS"),
        size: "+\(.additions) -\(.deletions) in \(.changedFiles) files",
        unresolved_threads: ([.reviewThreads.nodes[]? | select(.isResolved | not)] | length),
        your_pending_review: (([.reviews.nodes[]? | select((.author.login // "") == $login)] | length) > 0),
        updatedAt
      }]
    },
    assigned_issues: {
      total: .data.assignedIssues.issueCount,
      items: [.data.assignedIssues.nodes[] | {
        repo: .repository.nameWithOwner, number, title, url,
        labels: [.labels.nodes[]?.name],
        updatedAt
      }]
    },
    mentions: {
      total: .data.mentions.issueCount,
      items: [.data.mentions.nodes[]
        | select(.__typename == "Issue" or .__typename == "PullRequest")
        | {
        repo: .repository.nameWithOwner, number, title, url,
        kind: .__typename,
        author: (.author.login // "ghost"),
        updatedAt
      }]
    }
  }'
