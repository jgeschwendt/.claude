#!/usr/bin/env bash
# archive-transcript.sh — compact-delete a session's transcript(s): gzip-archive to the
# diary (~/.claude/@log/archive/<date>/), then remove the live .jsonl so the session is
# un-resumable. Marker-driven and idempotent — the zsh wrapper (shell/claude.zsh) and the
# detached watcher fallback can both fire; the mkdir lock makes double-fire harmless.
#
# Modes:
#   --now <sid>              gzip-copy NOW, CLI still alive (no rm — the live file would
#                            just be recreated; --finalize supersedes this copy later)
#   --finalize <sid>         CLI dead: re-gzip (captures the final flush), rm live .jsonl,
#                            rm handoff, rm marker. No-op without a marker.
#   --watch <sid> <cli_pid>  poll until the CLI dies, then finalize (unwrapped fallback;
#                            caller detaches via `nohup … & disown`)
#   --sweep-stale            finalize markers >60 min old whose transcripts are quiet
#                            (>10 min since last write) — never races a live session
#
# CLAUDE_HOME is overridable for tests only.
set -u

CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
PROJECTS="$CLAUDE_HOME/projects"
MARKERS="$CLAUDE_HOME/@log/.archive-on-exit"
HANDOFFS="$CLAUDE_HOME/@handoffs"

transcripts() { # $1=sid — one path per line, empty if none
  shopt -s nullglob
  local t
  for t in "$PROJECTS"/*/"$1".jsonl; do echo "$t"; done
  shopt -u nullglob
}

archive_copy() { # $1=transcript path — gzip-copy into today's diary dir
  local dir="$CLAUDE_HOME/@log/archive/$(date +%F)"
  mkdir -p "$dir"
  gzip -c "$1" > "$dir/$(basename "$1").gz"
}

now() { # $1=sid
  local t found=0
  while IFS= read -r t; do
    [ -n "$t" ] || continue
    archive_copy "$t" && found=1 && echo "  ▸ archived: $t"
  done <<< "$(transcripts "$1")"
  [ "$found" = 1 ] || echo "  ✻ no live transcript for $1 (nothing to archive yet)"
}

finalize() { # $1=sid — requires marker; lock guards concurrent finalizers
  local sid="$1" marker="$MARKERS/$1" lock="$MARKERS/$1.lock"
  [ -f "$marker" ] || return 0
  mkdir "$lock" 2>/dev/null || return 0
  trap 'rmdir "$lock" 2>/dev/null' EXIT
  local t
  while IFS= read -r t; do
    [ -n "$t" ] || continue
    archive_copy "$t" && rm -f "$t"
  done <<< "$(transcripts "$sid")"
  rm -f "$HANDOFFS/$sid.md" "$marker"
  rmdir "$lock" 2>/dev/null
  trap - EXIT
}

watch() { # $1=sid $2=cli_pid
  while kill -0 "$2" 2>/dev/null; do sleep 0.3; done
  sleep 0.6 # let the OS flush/close the file
  finalize "$1"
}

sweep_stale() {
  [ -d "$MARKERS" ] || return 0
  local now m sid t quiet l
  now=$(date +%s)
  # clear locks abandoned by a killed finalizer (>1 h) — they'd silently block that sid forever
  for l in "$MARKERS"/*.lock; do
    [ -d "$l" ] || continue
    [ $(( now - $(stat -f %m "$l") )) -gt 3600 ] && rmdir "$l" 2>/dev/null
  done
  for m in "$MARKERS"/*; do
    [ -f "$m" ] || continue
    sid=$(basename "$m")
    [ $(( now - $(stat -f %m "$m") )) -gt 3600 ] || continue
    # ephemeral forks stay marked while LIVE, and the CLI holds no open fd on the
    # transcript (lsof-verified) — so only mtime says whether a session is alive.
    # Reap only transcripts quiet >24 h; a fork's own wrapper finalizes it promptly.
    quiet=1
    while IFS= read -r t; do
      [ -n "$t" ] || continue
      [ $(( now - $(stat -f %m "$t") )) -gt 86400 ] || quiet=0
    done <<< "$(transcripts "$sid")"
    [ "$quiet" = 1 ] && finalize "$sid"
  done
  return 0
}

case "${1:-}" in
  --now)         now "${2:?sid required}" ;;
  --finalize)    finalize "${2:?sid required}" ;;
  --watch)       watch "${2:?sid required}" "${3:?cli_pid required}" ;;
  --sweep-stale) sweep_stale ;;
  *) echo "usage: archive-transcript.sh --now <sid> | --finalize <sid> | --watch <sid> <pid> | --sweep-stale" >&2; exit 2 ;;
esac
