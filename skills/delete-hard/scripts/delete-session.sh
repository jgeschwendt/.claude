#!/usr/bin/env bash
# delete-session.sh — close THIS session after `/delete hard` has erased it, and make sure
# the erase survives the CLI's own exit. Used by nothing else: ending a session normally is
# the SessionEnd router's job, and un-resumable-ness is no longer a goal (Claude Code keeps
# its transcripts, `cleanupPeriodDays: 3650`).
#
# Usage: delete-session.sh [scratchpad_dir]
#
# Flow: clean the scratchpad → resolve THIS session's CLI process (ancestor-only, never a
# sibling) → detach a watcher that erases the transcript the CLI writes on its way out →
# close the CLI (Ctrl-C twice, escalating to SIGTERM).
#
# The watcher is the load-bearing half. `orrery erase` erases the live `.jsonl` while the
# CLI is still running, and the CLI's final flush RE-CREATES it — a write that happens
# after every in-session tool call has returned, so nothing in-session can prevent it. The
# watcher outlives the CLI, waits for the pid to die, and erases whatever regrew.
#
# Nothing is ever archived, copied, or buffered here. `/delete hard` is the ending that
# leaves nothing.
set -u

FLUSH_GRACE_SECONDS=0.6
INT_GAP_SECONDS=0.4
SIGNAL_GRACE_SECONDS=0.6
WATCH_POLL_SECONDS=0.3

cli="$HOME/.orrery/bin/orrery"
if [ ! -x "$cli" ]; then
  echo "  ✻ orrery CLI not linked (~/.orrery/bin/orrery) — run bin/orrery link from the clone." >&2
  exit 1
fi
. "$(dirname "$(readlink -f "$cli")")/lib/lifecycle.sh"

scratchpad="${1:-}"

# ─── clean scratchpad (session-isolated — safe to rm) ──────────────────────────
if [ -n "$scratchpad" ] && [ -d "$scratchpad" ] && printf '%s' "$scratchpad" | grep -q '/scratchpad$'; then
  rm -rf "${scratchpad:?}/"* 2>/dev/null
  echo "  ▸ cleaned scratchpad: $scratchpad"
fi

sid="$(orrery_sid)"
if ! orrery_component "$sid"; then
  echo "  ✻ No usable session id — can't identify the conversation to close. Type /exit."
  exit 1
fi

# ─── resolve THIS session's CLI process (ancestor only — never a sibling) ──────
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
  echo "  ✻ Could not identify this session's CLI process safely — nothing closed."
  echo "    Interactive: type /exit. Background agent: stop it from outside"
  echo "    (claude stop <short-id>). The erase already ran; re-run orrery erase"
  echo "    afterwards to remove the transcript the exit flush re-creates."
  exit 0
fi

# ─── the regrowth watcher ─────────────────────────────────────────────────────
# Detached so it outlives the CLI. The child gets its inputs as ARGUMENTS, so no path can
# reshape the command it runs; it polls until the pid is gone, waits out the OS flush, and
# removes any `<sid>.jsonl` that came back in any project dir. No nullglob in the child —
# the `-f` test is what makes an unmatched glob a no-op.
# shellcheck disable=SC2016
nohup bash -c '
  sid="$1"; pid="$2"; projects="$3"; poll="$4"; flush="$5"
  while kill -0 "$pid" 2>/dev/null; do sleep "$poll"; done
  sleep "$flush"
  for t in "$projects"/*/"$sid".jsonl; do
    [ -f "$t" ] && rm -f "$t"
  done
' _ "$sid" "$cli_pid" "$ORRERY_PROJECTS_DIR" "$WATCH_POLL_SECONDS" "$FLUSH_GRACE_SECONDS" \
  >/dev/null 2>&1 &
disown

echo "  ▸ Conversation $sid is erased; the exit flush is watched and erased too."

# ─── close the session: Ctrl-C twice, escalate to TERM ────────────────────────
# A session with no controlling TTY (a `claude -p` run, a detached job) absorbs these
# signals as turn-cancels, so don't pretend: report plainly that it must be stopped from
# outside. The erase and the watcher are already secured either way.
alive() { kill -0 "$1" 2>/dev/null; }
cli_tty=$(ps -o tty= -p "$cli_pid" 2>/dev/null | tr -d ' ')
if [ -z "$cli_tty" ] || [ "$cli_tty" = "??" ]; then
  echo "  ✻ No TTY on CLI pid $cli_pid — in-session signals cannot close it. Stop it from"
  echo "    outside (claude stop <short-id>, or kill $cli_pid); the watcher erases the"
  echo "    transcript whenever the process exits."
  exit 0
fi

echo "  Closing session (CLI pid $cli_pid)…"
kill -INT "$cli_pid" 2>/dev/null; sleep "$INT_GAP_SECONDS"
kill -INT "$cli_pid" 2>/dev/null; sleep "$SIGNAL_GRACE_SECONDS"
if alive "$cli_pid"; then kill -TERM "$cli_pid" 2>/dev/null; sleep "$SIGNAL_GRACE_SECONDS"; fi
if alive "$cli_pid"; then
  echo "  ✻ Still running — signals absorbed. Type /exit; the watcher erases the transcript once the process exits."
fi
