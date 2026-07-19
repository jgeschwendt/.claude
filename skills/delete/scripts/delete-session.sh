#!/usr/bin/env bash
# delete-session.sh — kill THIS session: archive its transcript immediately, schedule
# the post-exit finalize (un-resumable), and close the CLI.
#
# Canonical kill used by BOTH skills:
#   /delete   — kill only (the session had no value)
#   /dissolve — enqueue for memory extraction first, THEN invoke /delete (the archive
#               this script writes is exactly what the sweep's queue consumer reads)
#
# The MODEL stops the specific background jobs it started BEFORE calling this.
#
# Flow: archive NOW (gzip copy secured while the CLI is alive) → write the
# archive-on-exit marker → post-exit finalize re-archives the final flush and removes
# the live .jsonl. Wrapped sessions (skills/delete/claude.zsh exports CLAUDE_WRAPPER_STATE):
# the wrapper finalizes deterministically after exit and respawns an ephemeral fork in
# the same terminal. Unwrapped: a detached watcher finalizes; no respawn is possible.
# Finally we signal the CLI to exit (Ctrl-C twice, escalating to SIGTERM).
#
# Usage: delete-session.sh [scratchpad_dir]
set -u

scratchpad="${1:-}"
sid="${CLAUDE_CODE_SESSION_ID:-}"
scripts="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
markers="$HOME/.claude/@log/.archive-on-exit"

# ─── clean scratchpad (session-isolated — safe to rm) ───────────────────────────
if [ -n "$scratchpad" ] && [ -d "$scratchpad" ] && printf '%s' "$scratchpad" | grep -q '/scratchpad$'; then
  rm -rf "${scratchpad:?}/"* 2>/dev/null
  echo "▸ cleaned scratchpad: $scratchpad"
fi

if [ -z "$sid" ]; then
  echo "  ✻ No CLAUDE_CODE_SESSION_ID — can't identify the conversation to delete. Type /exit to close."
  exit 1
fi

# ─── resolve THIS session's CLI process (ancestor only — never a sibling) ───────
resolve_cli_pid() {
  local pid comm
  pid=$PPID
  while [ -n "$pid" ] && [ "$pid" -gt 1 ]; do
    comm=$(ps -o comm= -p "$pid" 2>/dev/null | sed 's#.*/##' | tr -d ' ')
    [ "$comm" = "claude" ] && { echo "$pid"; return 0; }
    pid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
  done
  return 1
}
cli_pid="$(resolve_cli_pid || true)"

if [ -z "$cli_pid" ]; then
  echo "  ✻ Could not identify this session's CLI process safely — nothing killed."
  echo "    Type /exit to close, then archive manually: archive-transcript.sh --finalize $sid"
  exit 0
fi

# ─── archive NOW, mark for post-exit finalize ───────────────────────────────────
mkdir -p "$markers"
: > "$markers/$sid"
bash "$scripts/archive-transcript.sh" --now "$sid"

if [ -n "${CLAUDE_WRAPPER_STATE:-}" ] && [ -d "$CLAUDE_WRAPPER_STATE" ]; then
  # tell the wrapper which sid we actually killed (covers /clear rotating the sid)
  printf '%s\n' "$sid" >> "$CLAUDE_WRAPPER_STATE/finalize"
  : > "$CLAUDE_WRAPPER_STATE/respawn"
  echo "  ▸ wrapped session — the wrapper will respawn an ephemeral fork here."
else
  echo "  ▸ unwrapped session — no respawn."
fi

# watcher runs regardless (idempotent via lock) — finalize must not depend on the
# wrapper surviving, e.g. the terminal window closing right after the kill
nohup bash "$scripts/archive-transcript.sh" --watch "$sid" "$cli_pid" >/dev/null 2>&1 &
disown

echo "  ▸ Conversation $sid is archived to the @log archive and will be un-resumable on exit."

# ─── close the session: Ctrl-C twice, escalate to TERM ──────────────────────────
alive() { kill -0 "$1" 2>/dev/null; }
echo "  Closing session (CLI pid $cli_pid)…"
kill -INT "$cli_pid" 2>/dev/null; sleep 0.4
kill -INT "$cli_pid" 2>/dev/null; sleep 0.6
if alive "$cli_pid"; then kill -TERM "$cli_pid" 2>/dev/null; sleep 0.6; fi
if alive "$cli_pid"; then
  echo "  ✻ Still running — signals absorbed. Type /exit; the marker guarantees the transcript finalizes once the process exits."
fi
