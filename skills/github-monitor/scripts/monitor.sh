#!/usr/bin/env bash
# monitor.sh — GitHub monitor daemon with per-session repo scoping.
#
# The daemon polls GitHub (via gh_dashboard.sh) every INTERVAL seconds, diffs
# against the previous snapshot, and routes notification events to attached
# sessions using this rule:
#
#   * a session attached with a repo scope receives only that repo's events
#   * a session attached globally receives every event EXCEPT those for
#     repos currently claimed by a live repo-scoped session
#   * claims are released when the scoped session detaches or goes stale
#     (no poll for SESSION_TTL seconds, default 2h)
#
# Commands:
#   monitor.sh attach [--repo O/R | --global]
#         Register this conversation. By default auto-detects a repo scope
#         from the cwd (a git clone => scoped to that repo; anywhere else
#         => global). Starts the daemon if it isn't running. Prints
#         {"session": ..., "scope": ..., "daemon": ...}
#   monitor.sh poll <session>     Drain pending events (JSONL; empty = no news)
#   monitor.sh detach <session>   Unregister (releases any repo claim)
#   monitor.sh status             Daemon + sessions overview (JSON)
#   monitor.sh start [--interval N]   Start daemon explicitly (idempotent)
#   monitor.sh stop               Stop the daemon (sessions are kept)
#   monitor.sh tick               Run one poll cycle in the foreground (debug)
#   monitor.sh hook-config        Print the Claude Code settings.json hooks
#                                 snippet that turns delivery into push (see
#                                 hook_poll.sh)
#
# State lives in ${GITHUB_MONITOR_DIR:-~/.local/state/github-monitor}.
# Requires: gh (authenticated), jq.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIR="${GITHUB_MONITOR_DIR:-$HOME/.local/state/github-monitor}"
SESS="$DIR/sessions"; QUEUES="$DIR/queues"
PIDFILE="$DIR/daemon.pid"; LOG="$DIR/daemon.log"; STATE="$DIR/state.json"
INTERVAL_FILE="$DIR/interval"
SESSION_TTL="${GITHUB_MONITOR_SESSION_TTL:-7200}"
mkdir -p "$SESS" "$QUEUES"

log() { echo "[$(date -u +%FT%TZ)] $*" >> "$LOG"; }
die_json() { echo "{\"error\":\"$1\",\"hint\":\"$2\"}" >&2; exit 1; }

need_tools() {
  command -v gh >/dev/null 2>&1 || die_json gh_not_installed "Install the GitHub CLI: https://cli.github.com"
  command -v jq >/dev/null 2>&1 || die_json jq_not_installed "Install jq (apt install jq / brew install jq)"
}

daemon_alive() { [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE" 2>/dev/null)" 2>/dev/null; }

interval() { cat "$INTERVAL_FILE" 2>/dev/null || echo 120; }

repo_from_cwd() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 1
  local slug url
  if slug="$(gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null)" && [ -n "$slug" ]; then
    echo "$slug"; return 0
  fi
  url="$(git remote get-url origin 2>/dev/null)" || return 1
  echo "$url" | sed -E 's#^(git@[^:]+:|[a-zA-Z]+://[^/]+/)##; s#\.git$##' | grep -E '^[^/]+/[^/]+$'
}

prune_sessions() {
  local ttl_min=$(( SESSION_TTL / 60 )); [ "$ttl_min" -lt 1 ] && ttl_min=1
  local sf id
  for sf in "$SESS"/*.json; do
    [ -e "$sf" ] || continue
    if [ -n "$(find "$sf" -mmin +"$ttl_min" 2>/dev/null)" ]; then
      id="$(basename "$sf" .json)"
      log "pruning stale session $id"
      rm -f "$sf" "$QUEUES/$id.jsonl"
    fi
  done
}

broadcast_all() { # $1 = one event json line -> every session
  local sf id
  for sf in "$SESS"/*.json; do
    [ -e "$sf" ] || continue
    id="$(basename "$sf" .json)"
    echo "$1" >> "$QUEUES/$id.jsonl"
  done
}

route_events() { # $1 = JSON array of events
  prune_sessions
  local claimed evt repo sf id scope
  claimed="$(jq -r '.scope // empty' "$SESS"/*.json 2>/dev/null | sort -u || true)"
  while IFS= read -r evt; do
    [ -n "$evt" ] || continue
    repo="$(echo "$evt" | jq -r '.repo // ""')"
    for sf in "$SESS"/*.json; do
      [ -e "$sf" ] || continue
      id="$(basename "$sf" .json)"
      scope="$(jq -r '.scope // ""' "$sf")"
      if [ -n "$scope" ]; then
        # repo-scoped session: only its own repo's events
        if [ "$scope" = "$repo" ]; then echo "$evt" >> "$QUEUES/$id.jsonl"; fi
      else
        # global session: everything except repos claimed by live scoped sessions
        if [ -z "$repo" ] || ! printf '%s\n' "$claimed" | grep -qxF "$repo"; then
          echo "$evt" >> "$QUEUES/$id.jsonl"
        fi
      fi
    done
  done < <(echo "$1" | jq -c '.[]')
}

# ✻ body hoisted out of run_tick's $() — bash 3.2 (macOS default) cannot parse `case` inside command substitution
resolve_disappeared() { # stdin/stdout: event JSON lines; pr_disappeared -> pr_merged | pr_closed
  local e u st
  while IFS= read -r e; do
    if [ "$(echo "$e" | jq -r .type)" = "pr_disappeared" ]; then
      u="$(echo "$e" | jq -r .url)"
      st="$(gh pr view "$u" --json state --jq .state 2>/dev/null || echo UNKNOWN)"
      case "$st" in
        MERGED) e="$(echo "$e" | jq -c '.type="pr_merged" | .title=(.title | sub(" — no longer open$"; " — merged 🎉"))')" ;;
        CLOSED) e="$(echo "$e" | jq -c '.type="pr_closed" | .title=(.title | sub(" — no longer open$"; " — closed without merging"))')" ;;
      esac
    fi
    echo "$e"
  done
}

run_tick() {
  need_tools
  local raw new old events resolved n
  if ! raw="$(bash "$SCRIPT_DIR/gh_dashboard.sh" 50 2>>"$LOG")"; then
    log "dashboard fetch failed; skipping tick"
    return 0
  fi
  new="$(echo "$raw" | jq -c '{
    mine: ([.my_prs.items[] | {key: (.repo + "#" + (.number|tostring)),
      value: {repo, title, url, draft, ci, review, mergeable,
              nyr: .review_comments.needs_your_reply}}] | from_entries),
    rr: ([.review_requests.items[] | {key: (.repo + "#" + (.number|tostring)),
      value: {repo, title, url, draft, author}}] | from_entries),
    issues: ([.assigned_issues.items[] | {key: (.repo + "#" + (.number|tostring)),
      value: {repo, title, url}}] | from_entries)
  }')"
  if [ ! -f "$STATE" ]; then
    printf '%s\n' "$new" > "$STATE.tmp" && mv "$STATE.tmp" "$STATE"
    local mine_n rr_n
    mine_n="$(echo "$raw" | jq '.my_prs.total')"
    rr_n="$(echo "$raw" | jq '.review_requests.total')"
    broadcast_all "$(jq -cn \
      --arg t "Monitoring started: baseline captured ($mine_n open PRs, $rr_n review requests). Changes will be reported from now on." \
      '{ts:(now|todate),repo:null,type:"monitor_started",severity:"info",title:$t,url:null}')"
    log "baseline captured ($mine_n PRs, $rr_n review requests)"
    return 0
  fi
  old="$(cat "$STATE")"
  events="$(jq -cn --argjson old "$old" --argjson new "$new" -f "$SCRIPT_DIR/diff_events.jq")"
  # Resolve disappeared own PRs into merged vs closed (one cheap lookup each).
  resolved="$(echo "$events" | jq -c '.[]' | resolve_disappeared | jq -cs '.')"
  n="$(echo "$resolved" | jq 'length')"
  if [ "$n" -gt 0 ]; then
    log "tick: $n event(s)"
    route_events "$resolved"
  fi
  printf '%s\n' "$new" > "$STATE.tmp" && mv "$STATE.tmp" "$STATE"
}

cmd_start() {
  need_tools
  local iv=""
  while [ $# -gt 0 ]; do case "$1" in --interval) iv="$2"; shift 2 ;; *) shift ;; esac; done
  if [ -n "$iv" ]; then echo "$iv" > "$INTERVAL_FILE"; fi
  if daemon_alive; then
    jq -cn --arg pid "$(cat "$PIDFILE")" --arg iv "$(interval)" \
      '{daemon:"already_running",pid:($pid|tonumber),interval_seconds:($iv|tonumber)}'
    return 0
  fi
  nohup bash "$0" _daemon >> "$LOG" 2>&1 &
  echo $! > "$PIDFILE"
  disown 2>/dev/null || true
  jq -cn --arg pid "$(cat "$PIDFILE")" --arg iv "$(interval)" \
    '{daemon:"started",pid:($pid|tonumber),interval_seconds:($iv|tonumber)}'
}

cmd__daemon() {
  echo $$ > "$PIDFILE"
  trap 'log "daemon exiting"; exit 0' TERM INT
  log "daemon started pid $$ interval $(interval)s"
  while :; do
    run_tick || log "tick error (status $?)"
    sleep "$(interval)"
  done
}

cmd_attach() {
  need_tools
  local scope="" mode="auto"
  while [ $# -gt 0 ]; do case "$1" in
    --repo) scope="$2"; mode="explicit"; shift 2 ;;
    --global) mode="global"; shift ;;
    *) shift ;;
  esac; done
  if [ "$mode" = "auto" ]; then scope="$(repo_from_cwd || true)"; fi
  if [ "$mode" = "global" ]; then scope=""; fi
  local id="s$(date +%s)$RANDOM"
  jq -cn --arg id "$id" --arg scope "$scope" \
    '{session:$id, scope:(if $scope=="" then null else $scope end), created:(now|todate)}' \
    > "$SESS/$id.json"
  : > "$QUEUES/$id.jsonl"
  local started="already_running"
  if ! daemon_alive; then cmd_start >/dev/null; started="started"; fi
  jq -c --arg d "$started" '. + {daemon:$d}' "$SESS/$id.json"
}

cmd_poll() {
  local id="${1:-}"
  [ -n "$id" ] || die_json missing_session "Usage: monitor.sh poll <session-id>"
  [ -f "$SESS/$id.json" ] || die_json unknown_session "No such session (expired or detached); attach again"
  touch "$SESS/$id.json"   # heartbeat: keeps this session's repo claim alive
  local q="$QUEUES/$id.jsonl" tmp
  [ -s "$q" ] || return 0
  tmp="$q.draining.$$"
  mv "$q" "$tmp"           # atomic: concurrent daemon appends create a fresh queue
  cat "$tmp"
  rm -f "$tmp"
}

cmd_detach() {
  local id="${1:-}"
  [ -n "$id" ] || die_json missing_session "Usage: monitor.sh detach <session-id>"
  rm -f "$SESS/$id.json" "$QUEUES/$id.jsonl"
  echo "{\"detached\":\"$id\"}"
}

cmd_status() {
  local running=false pid=null sessions="[]" sf id mt
  if daemon_alive; then running=true; pid="$(cat "$PIDFILE")"; fi
  for sf in "$SESS"/*.json; do
    [ -e "$sf" ] || continue
    id="$(basename "$sf" .json)"
    mt="$(stat -c %Y "$sf" 2>/dev/null || stat -f %m "$sf" 2>/dev/null || date +%s)"
    sessions="$(jq -c \
      --argjson s "$(jq -c . "$sf")" \
      --arg q "$( { wc -l < "$QUEUES/$id.jsonl"; } 2>/dev/null || echo 0)" \
      --arg age "$(( $(date +%s) - mt ))" \
      '. + [$s + {queued:($q|tonumber), seconds_since_poll:($age|tonumber)}]' <<< "$sessions")"
  done
  jq -cn --argjson running "$running" --argjson pid "$pid" \
    --arg iv "$(interval)" --argjson sessions "$sessions" \
    '{daemon:{running:$running,pid:$pid,interval_seconds:($iv|tonumber)},sessions:$sessions}'
}

cmd_hook_config() {
  command -v jq >/dev/null 2>&1 || die_json jq_not_installed "Install jq (apt install jq / brew install jq)"
  local hp="$SCRIPT_DIR/hook_poll.sh"
  jq -n --arg cmd "bash $hp" '{hooks:{
    UserPromptSubmit:[{hooks:[{type:"command",command:$cmd,timeout:20}]}],
    SessionEnd:[{hooks:[{type:"command",command:$cmd}]}]
  }}'
}

cmd_stop() {
  if daemon_alive; then
    kill "$(cat "$PIDFILE")" 2>/dev/null || true
    rm -f "$PIDFILE"
    echo '{"daemon":"stopped"}'
  else
    rm -f "$PIDFILE"
    echo '{"daemon":"not_running"}'
  fi
}

case "${1:-}" in
  start)  shift; cmd_start "$@" ;;
  attach) shift; cmd_attach "$@" ;;
  poll)   shift; cmd_poll "$@" ;;
  detach) shift; cmd_detach "$@" ;;
  status) cmd_status ;;
  stop)   cmd_stop ;;
  hook-config) cmd_hook_config ;;
  tick)   run_tick ;;
  _daemon) cmd__daemon ;;
  *) sed -n '2,32p' "$0" | sed 's/^# \{0,1\}//'; exit 1 ;;
esac
