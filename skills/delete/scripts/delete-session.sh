#!/usr/bin/env bash
# delete-session.sh — kill THIS session: compact-delete its transcript (un-resumable) and exit.
#
# Canonical kill used by BOTH skills:
#   /delete   — kill only (the session had no value)
#   /dissolve — extract memories first, THEN call this to kill
#
# The MODEL stops the specific background jobs it started BEFORE calling this.
# Deleting the live .jsonl now would just be recreated on the way out, so a
# detached setsid watcher (immune to the CLI's exit signals) waits for the CLI
# process to die and THEN compact-deletes the transcript(s): each is gzip-archived
# under ~/.claude/@log/archive/<date>/ (recoverable, ~10x smaller, fuel for the
# diary's daily dream) instead of erased; the ephemeral handoff is removed. Finally
# we signal the CLI to exit (Ctrl-C twice, escalating to SIGTERM). Still un-resumable
# afterward — `claude --resume` needs a LIVE .jsonl, not an archive.
#
# Usage: delete-session.sh [scratchpad_dir]
set -u

scratchpad="${1:-}"
sid="${CLAUDE_CODE_SESSION_ID:-}"
projects="$HOME/.claude/projects"
handoff="$HOME/.claude/@handoffs/${sid}.md"

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

shopt -s nullglob
transcripts=( "$projects"/*/"${sid}.jsonl" )
shopt -u nullglob

if [ -z "$cli_pid" ]; then
  echo "  ✻ Could not identify this session's CLI process safely — transcript NOT deleted."
  echo "    Type /exit to close, then delete manually:"
  for t in "${transcripts[@]}"; do echo "      rm $t"; done
  exit 0
fi

# ─── detached watcher: compact-delete transcript(s) + drop handoff after CLI exits ──
# .jsonl transcripts are gzip-archived into the diary (recoverable); everything else
# (the handoff) is removed. Deleting nothing live until the CLI is gone.
python3 -c '
import os, sys, time, gzip, shutil, datetime
os.setsid()                      # new session: immune to the CLI process-group exit signals
cli = int(sys.argv[1]); paths = sys.argv[2:]
def alive(p):
    try: os.kill(p, 0); return True
    except OSError: return False
while alive(cli): time.sleep(0.3)
time.sleep(0.6)                  # let the OS flush/close the file
archdir = os.path.expanduser("~/.claude/@log/archive/" + datetime.date.today().isoformat())
for p in paths:
    try:
        if p.endswith(".jsonl") and os.path.exists(p):
            os.makedirs(archdir, exist_ok=True)
            with open(p, "rb") as f, gzip.open(os.path.join(archdir, os.path.basename(p) + ".gz"), "wb") as g:
                shutil.copyfileobj(f, g)
            os.remove(p)
        else:
            os.remove(p)
    except OSError: pass
' "$cli_pid" "${transcripts[@]}" "$handoff" >/dev/null 2>&1 &
disown

echo "  ▸ Conversation $sid will be compact-deleted on exit — archived to the diary, not resumable."
for t in "${transcripts[@]}"; do echo "      $t"; done

# ─── close the session: Ctrl-C twice, escalate to TERM ──────────────────────────
alive() { kill -0 "$1" 2>/dev/null; }
echo "  Closing session (CLI pid $cli_pid)…"
kill -INT "$cli_pid" 2>/dev/null; sleep 0.4
kill -INT "$cli_pid" 2>/dev/null; sleep 0.6
if alive "$cli_pid"; then kill -TERM "$cli_pid" 2>/dev/null; sleep 0.6; fi
if alive "$cli_pid"; then
  echo "  ✻ Still running — signals absorbed. Type /exit; the transcript will be archived once the process exits."
fi
