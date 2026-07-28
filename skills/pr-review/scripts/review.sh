#!/usr/bin/env bash
# review.sh — one round of the standing review conversation for one PR.
#
# Usage: review.sh <pr-ref> [--post] [--force]
#
#   <pr-ref>  https://github.com/OWNER/REPO/pull/N · OWNER/REPO#N · OWNER/REPO N · N · #N
#   --post    also post the round's body as a PR comment (failure warns, never fatal)
#   --force   re-run even when the head SHA is already the reviewed one
#
# The conversation is the unit, not the call: round 1 mints a session id and seeds it with
# the whole PR; every later round RESUMES that same session and is handed only the delta
# since `last_head` plus current thread state, so the reviewer re-judges its own numbered
# findings instead of re-deriving them. Resume is project-dir-keyed, which is why `cwd` is
# stored in round 1 and every later round cd's back into it before calling.
#
# Write order after a successful call is residue → journal → cache, deliberately, and
# nothing is written after a failed one. `round-<n>.md` is the durable artifact; the ledger
# line NAMES a residue file that already exists; `state.json` is only a cache of the ledger
# tail, so a crash between the append and the rewrite loses a derivable fact, never a
# review. The reverse order would leave a cache pointing at a round nobody can read.
#
# Exactly one claude call per round, and zero when the head SHA has not moved — the no-op
# guard fires before any fetch of the diff. Calls are hermetic and memory-blind
# (CLAUDE_MEMORY_PIPELINE=1, --setting-sources '') so a review never reads the user's
# memory banks and never feeds them.
#
# Env: PR_REVIEW_ROOT · PR_REVIEW_MODEL · PR_REVIEW_DRY · PR_REVIEW_DIFF_CAP ·
#      PR_REVIEW_THREADS_CAP  (see the block below)
#
# Output: stdout is the round's review body (the round-<n>.md content) and nothing else;
#         progress and the summary go to stderr.
set -euo pipefail

PR_REVIEW_ROOT="${PR_REVIEW_ROOT:-$HOME/.orrery/reviews}"
PR_REVIEW_MODEL="${PR_REVIEW_MODEL:-opus}"
PR_REVIEW_DRY="${PR_REVIEW_DRY:-0}"
PR_REVIEW_DIFF_CAP="${PR_REVIEW_DIFF_CAP:-50000}"
PR_REVIEW_THREADS_CAP="${PR_REVIEW_THREADS_CAP:-20000}"

THREADS_SCRIPT="$HOME/.claude/skills/monitor-github/scripts/pr_review_threads.sh"
SHA_SHORT=7

die() { echo "$*" >&2; exit 1; }
note() { echo "  ▸ $*" >&2; }
warn() { echo "  ✻ $*" >&2; }

# ─── caps ─────────────────────────────────────────────────────────────────────
# Two shapes: threads keep their head (the JSON prefix stays parseable-looking, and the
# newest state is what matters), diffs keep head AND tail — a truncated patch loses its
# middle, never the files at either end of the walk.

cap_head() { # $1=text $2=cap
  if [ "${#1}" -le "$2" ]; then printf '%s' "$1"; return 0; fi
  printf '%s\n[... truncated %s chars ...]' "${1:0:$2}" "$(( ${#1} - $2 ))"
}

cap_middle() { # $1=text $2=cap
  if [ "${#1}" -le "$2" ]; then printf '%s' "$1"; return 0; fi
  printf '%s\n[... truncated %s chars ...]\n%s' \
    "${1:0:$(( $2 / 2 ))}" "$(( ${#1} - $2 ))" "${1:$(( ${#1} - $2 / 2 ))}"
}

# ─── arguments ────────────────────────────────────────────────────────────────

POST=0
FORCE=0
ARGS=()
for a in "$@"; do
  case "$a" in
    --force) FORCE=1 ;;
    --post) POST=1 ;;
    -*) die "review.sh: unknown flag $a (usage: review.sh <pr-ref> [--post] [--force])" ;;
    *) ARGS+=("$a") ;;
  esac
done
[ "${#ARGS[@]}" -ge 1 ] || die "usage: review.sh <pr-ref> [--post] [--force]"

# Same three shapes pr_review_threads.sh accepts, plus a bare number resolved against the
# repo the caller is standing in.
if [[ "${ARGS[0]}" =~ ^https?://[^/]+/([^/]+)/([^/]+)/pull/([0-9]+) ]]; then
  OWNER="${BASH_REMATCH[1]}"; REPO="${BASH_REMATCH[2]}"; NUMBER="${BASH_REMATCH[3]}"
elif [[ "${ARGS[0]}" =~ ^([^/#[:space:]]+)/([^/#[:space:]]+)#([0-9]+)$ ]]; then
  OWNER="${BASH_REMATCH[1]}"; REPO="${BASH_REMATCH[2]}"; NUMBER="${BASH_REMATCH[3]}"
elif [ "${#ARGS[@]}" -ge 2 ] && [[ "${ARGS[1]}" =~ ^[0-9]+$ ]] && [[ "${ARGS[0]}" =~ ^([^/#[:space:]]+)/([^/#[:space:]]+)$ ]]; then
  OWNER="${BASH_REMATCH[1]}"; REPO="${BASH_REMATCH[2]}"; NUMBER="${ARGS[1]}"
elif [[ "${ARGS[0]}" =~ ^#?([0-9]+)$ ]]; then
  NUMBER="${BASH_REMATCH[1]}"
  nwo="$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null)" \
    || die "review.sh: '${ARGS[0]}' is a bare PR number and this is not a GitHub repo — cd into the repo, or pass OWNER/REPO#$NUMBER."
  OWNER="${nwo%%/*}"; REPO="${nwo#*/}"
else
  die "review.sh: cannot parse '${ARGS[0]}' — pass a PR URL, OWNER/REPO#NUM, OWNER/REPO NUM, or a bare number."
fi

SLUG="$(printf '%s' "$OWNER/$REPO/$NUMBER" | sed 's/[^A-Za-z0-9]/-/g')"
DIR="$PR_REVIEW_ROOT/$SLUG"
STATE_FILE="$DIR/state.json"

# ─── the PR ───────────────────────────────────────────────────────────────────

pr="$(gh pr view "$NUMBER" --repo "$OWNER/$REPO" \
  --json number,title,state,isDraft,author,baseRefName,headRefName,headRefOid,body,additions,deletions,changedFiles,url,mergedAt 2>&1)" \
  || die "review.sh: gh pr view failed for $OWNER/$REPO#$NUMBER — $pr"

title="$(jq -r '.title // ""' <<< "$pr")"
state="$(jq -r '.state // ""' <<< "$pr")"
draft="$(jq -r 'if .isDraft then "yes" else "no" end' <<< "$pr")"
author="$(jq -r '.author.login // "ghost"' <<< "$pr")"
base_ref="$(jq -r '.baseRefName // ""' <<< "$pr")"
head_ref="$(jq -r '.headRefName // ""' <<< "$pr")"
head="$(jq -r '.headRefOid // ""' <<< "$pr")"
body="$(jq -r '.body // ""' <<< "$pr")"
url="$(jq -r '.url // ""' <<< "$pr")"
stat="$(jq -r '"+\(.additions) −\(.deletions) across \(.changedFiles) files"' <<< "$pr")"
head7="${head:0:$SHA_SHORT}"

case "$state" in
  CLOSED|MERGED) warn "PR is $state — reviewing anyway (findings apply to a landed diff)." ;;
esac

# ─── state, and the no-op guard ───────────────────────────────────────────────

stored='{}'
if [ -s "$STATE_FILE" ]; then
  stored="$(jq -c '.' "$STATE_FILE" 2>/dev/null)" \
    || { warn "state.json unreadable — seeding a fresh conversation."; stored='{}'; }
fi
prev_round="$(jq -r '.round // 0' <<< "$stored")"
last_head="$(jq -r '.last_head // ""' <<< "$stored")"
session_id="$(jq -r '.session_id // ""' <<< "$stored")"
call_cwd="$(jq -r '.cwd // ""' <<< "$stored")"
created="$(jq -r '.created // ""' <<< "$stored")"

round=$(( prev_round + 1 ))
# A conversation with no session id cannot be resumed — seed a new one and keep counting.
seed=1
if [ -n "$session_id" ]; then seed=0; fi

if [ "$last_head" = "$head" ] && [ "$FORCE" = 0 ]; then
  echo "round $prev_round already reviewed $head7 — nothing new; --force to re-run" >&2
  exit 0
fi

note "$OWNER/$REPO#$NUMBER · round $round · head $head7"

# ─── review threads ───────────────────────────────────────────────────────────

threads='{}'
threads_note=''
if [ -f "$THREADS_SCRIPT" ]; then
  if ! threads="$(bash "$THREADS_SCRIPT" "$OWNER/$REPO" "$NUMBER" --all 2>/dev/null)"; then
    threads='{}'
    threads_note='NOTE: the review-thread fetch failed — thread state below is unknown, not empty.'
  fi
  [ -n "$threads" ] || threads='{}'
else
  threads_note='NOTE: pr_review_threads.sh is not installed — thread state below is unknown, not empty.'
fi
threads="$(cap_head "$threads" "$PR_REVIEW_THREADS_CAP")"

# ─── the diff for this round ──────────────────────────────────────────────────
# Round 1 reviews the whole PR; later rounds review only what landed since `last_head`.
# A force-push rewrites that base out of existence, so `.status == "diverged"` (and any
# compare failure) falls back to the full diff with the rewrite stated in the prompt.

COMPARE_JQ='
  "compare status: \(.status) · ahead_by \(.ahead_by) · behind_by \(.behind_by)",
  "",
  "commits in this delta:",
  (.commits[]? | "  \(.sha[0:7])  \(.commit.message | split("\n")[0])"),
  "",
  (.files[]? | select(.patch != null) | "─── \(.filename) ───\n\(.patch)")'

delta_source=''
diff=''
rewritten=0

if [ "$seed" = 1 ] || [ -z "$last_head" ]; then
  delta_source="full PR diff (seed round)"
  diff="$(gh pr diff "$url" 2>&1)" || die "review.sh: gh pr diff failed — $diff"
else
  compare=''
  status=''
  if compare="$(gh api "repos/$OWNER/$REPO/compare/$last_head...$head" 2>/dev/null)"; then
    status="$(jq -r '.status // ""' <<< "$compare")"
  fi
  if [ -z "$status" ] || [ "$status" = "diverged" ]; then
    rewritten=1
    delta_source="full PR diff (compare unusable: ${status:-fetch failed})"
    warn "compare ${last_head:0:$SHA_SHORT}...$head7 unusable (${status:-fetch failed}) — falling back to the full diff."
    diff="$(gh pr diff "$url" 2>&1)" || die "review.sh: gh pr diff failed — $diff"
  else
    delta_source="compare ${last_head:0:$SHA_SHORT}...$head7 ($status)"
    diff="$(jq -r "$COMPARE_JQ" <<< "$compare")"
  fi
fi
diff="$(cap_middle "$diff" "$PR_REVIEW_DIFF_CAP")"

# ─── the prompt ───────────────────────────────────────────────────────────────
# Two variants, never blended: the seed declares the standing contract once, the delta
# round leans on the conversation already holding it.

OUTPUT_CONTRACT="Respond through the JSON schema. \`verdict\` is one of approve · comment · request_changes. \`findings\` carries every finding you are standing behind THIS round, prior ones included, each with a stable \`id\` (F1, F2, … — never renumber, never reuse a retired id) and a \`status\`. \`body\` is the complete human-facing review in markdown: self-contained, readable without this prompt, and it starts with the heading:

## Review — round $round · $head7"

PRIORITIES="Review priorities, in order: correctness · security · API/contract regressions · tests · style. Raise style only when it is egregious. Say nothing about what is fine; a short review of a clean diff is the correct output."

if [ "$seed" = 1 ]; then
  prompt="$(cat <<EOF
You are the persistent reviewer for one pull request. THIS CONVERSATION WILL BE RESUMED for
every future round of this PR — each later round hands you only what changed since the head
you just reviewed, and asks you to re-judge the findings you are about to write. So keep
your findings NUMBERED AND STABLE (F1, F2, …): a future round will reference them by id and
you must be able to say whether each one was addressed, still stands, or went obsolete.

Round $round — the seed. You are seeing the whole PR.

PR: $OWNER/$REPO#$NUMBER — $title
Author: $author · State: $state · Draft: $draft
Branch: $head_ref → $base_ref · Head: $head
Size: $stat
URL: $url

── description ──
$body

── review threads (JSON; --all, resolved included) ──
$threads_note
$threads

── full diff ──
$diff

$PRIORITIES

You may read the repository (Read/Grep/Glob) and re-query GitHub with gh to check a
suspicion before you raise it. Do not report anything you have not grounded in the diff or
in the code around it.

$OUTPUT_CONTRACT
EOF
)"
else
  rewrite_notice=''
  if [ "$rewritten" = 1 ]; then rewrite_notice="
THE BASE FOR COMPARISON WAS REWRITTEN — the branch was force-pushed, so the delta since
$last_head no longer exists as a range. What follows is the FULL current diff, not a delta:
re-judge every prior finding against it from scratch, and treat code you recognise as
unchanged.
"; fi
  prompt="$(cat <<EOF
Round $round of this PR. Last reviewed head: $last_head.
$rewrite_notice
── what changed since $last_head ($delta_source) ──
$diff

── review threads now (JSON; --all, resolved included) ──
$threads_note
$threads

Do this in order:

1. **Prior findings** — a markdown table of EVERY finding you have raised in this
   conversation so far: id · severity · title · status (addressed / stands / obsolete) ·
   one line of evidence for that status (the commit, the hunk, the thread, or "not touched").
   A finding whose code the delta did not touch still \`stands\`; one whose subject the delta
   deleted or restructured away is \`obsolete\`. Carry all of them into \`findings\` with
   their original ids and their new status.
2. **New findings** — review the delta itself, on its own merits. New findings get the next
   free ids and status \`new\`.
3. **Verdict** — updated for the PR as it stands now, not for the delta alone.

$PRIORITIES

$OUTPUT_CONTRACT
EOF
)"
fi

# ─── the model call — exactly one ─────────────────────────────────────────────

if [ "$seed" = 1 ]; then
  new_sid="$(uuidgen | tr '[:upper:]' '[:lower:]')"
  session_flag=(--session-id "$new_sid")
  [ -n "$call_cwd" ] || call_cwd="$PWD"
else
  session_flag=(--resume "$session_id")
fi

if [ "$PR_REVIEW_DRY" != 0 ]; then
  echo "round: $round"
  echo "session flag: ${session_flag[*]}"
  echo "delta source: $delta_source"
  echo "cwd: $call_cwd"
  echo "─── prompt ───"
  echo "$prompt"
  exit 0
fi

[ -d "$call_cwd" ] || die "review.sh: the conversation's directory ($call_cwd) is gone — resume is project-dir-keyed, so restore it or delete $STATE_FILE to seed a fresh conversation."
cd "$call_cwd"

SCHEMA='{"type":"object","required":["verdict","findings","body"],"properties":{"verdict":{"enum":["approve","comment","request_changes"]},"findings":{"type":"array","items":{"type":"object","required":["id","severity","title","status"],"properties":{"id":{"type":"string"},"severity":{"enum":["blocker","major","minor","nit"]},"file":{"type":"string"},"title":{"type":"string"},"status":{"enum":["new","addressed","stands","obsolete"]},"note":{"type":"string"}}}},"body":{"type":"string"}}}'

note "calling $PR_REVIEW_MODEL from $call_cwd (${session_flag[0]}) …"
resp=''
if ! resp="$(CLAUDE_MEMORY_PIPELINE=1 claude -p \
  --model "$PR_REVIEW_MODEL" \
  --output-format json \
  --setting-sources '' \
  --disable-slash-commands \
  --allowed-tools "Read,Grep,Glob,Bash(gh pr view:*),Bash(gh pr diff:*),Bash(gh api:*)" \
  --json-schema "$SCHEMA" \
  "${session_flag[@]}" \
  -- "$prompt" 2>&1)"; then
  die "review.sh: the claude call failed — no state written. Output: $(printf '%s' "$resp" | tail -5)"
fi

# Stdout can carry hook noise around the payload, so scan for the result line rather than
# decoding the whole stream; `--json-schema` puts the validated object in structured_output.
result="$(printf '%s\n' "$resp" | jq -c -R 'fromjson? | select(.type == "result")' | tail -1)"
[ -n "$result" ] || die "review.sh: no result envelope in the claude output — no state written. Output: $(printf '%s' "$resp" | tail -5)"
jq -e '.is_error | not' <<< "$result" >/dev/null \
  || die "review.sh: claude reported an error — no state written: $(jq -r '.result // ""' <<< "$result")"

out="$(jq -c '.structured_output // (.result | fromjson? // empty)' <<< "$result")"
[ -n "$out" ] && [ "$out" != "null" ] \
  || die "review.sh: the reply carried no structured output — no state written."

new_sid="$(jq -r '.session_id // ""' <<< "$result")"
[ -n "$new_sid" ] || new_sid="$session_id"
verdict="$(jq -r '.verdict // "comment"' <<< "$out")"
findings="$(jq -c '.findings // []' <<< "$out")"
review="$(jq -r '.body // ""' <<< "$out")"
[ -n "$review" ] || die "review.sh: the reply carried an empty body — no state written."

# ─── persist: residue → journal → cache ───────────────────────────────────────

now="$(date -u +%FT%TZ)"
[ -n "$created" ] || created="$now"
mkdir -p "$DIR"

printf '%s\n' "$review" > "$DIR/round-$round.md"

# `base` is what this round's diff was actually taken against: the PR's base ref when the
# round read the whole PR (seed, or a force-push fallback), the previous head otherwise.
base_used="$last_head"
if [ "$seed" = 1 ] || [ "$rewritten" = 1 ]; then base_used="$base_ref"; fi

jq -cn --arg at "$now" --argjson round "$round" --arg head "$head" --arg base "$base_used" \
  --arg session_id "$new_sid" --arg verdict "$verdict" --argjson findings "$findings" \
  '{at: $at, round: $round, head: $head, base: $base, session_id: $session_id, verdict: $verdict, findings: $findings}' \
  >> "$DIR/ledger.jsonl"

jq -n --arg pr "$OWNER/$REPO#$NUMBER" --arg url "$url" --arg cwd "$call_cwd" \
  --arg session_id "$new_sid" --arg last_head "$head" --argjson round "$round" \
  --arg created "$created" --arg updated "$now" \
  '{pr: $pr, url: $url, cwd: $cwd, session_id: $session_id, last_head: $last_head, round: $round, created: $created, updated: $updated}' \
  | jq -c '.' > "$STATE_FILE"

# ─── report ───────────────────────────────────────────────────────────────────

printf '%s\n' "$review"

counts="$(jq -r 'group_by(.status) | map("\(.[0].status)=\(length)") | join(" ")' <<< "$findings")"
note "round $round · verdict $verdict · ${counts:-no findings} · $DIR/round-$round.md"

if [ "$POST" = 1 ]; then
  if gh pr comment "$url" --body-file "$DIR/round-$round.md" >&2; then
    note "posted round $round to $url"
  else
    warn "posting failed — the review is still on disk at $DIR/round-$round.md"
  fi
fi
