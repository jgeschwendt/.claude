#!/usr/bin/env bash
# enqueue.sh — append THIS session to the dissolve queue
# (~/.orrery/memory/.dissolve-queue.jsonl). The orrery pipeline worker consumes
# the queue promptly (hourly sweep as app-down backstop): extract → judge →
# commit into the cwd's bank, reading the transcript from
# the archive that /delete writes. Fast by design — ending a session must
# never wait on claude calls.
#
# Usage: enqueue.sh [title]
set -u

sid="${CLAUDE_CODE_SESSION_ID:-}"
if [ -z "$sid" ]; then
  echo "  ✻ No CLAUDE_CODE_SESSION_ID — can't identify the conversation to enqueue." >&2
  exit 1
fi

queue="$HOME/.orrery/memory/.dissolve-queue.jsonl"
mkdir -p "$(dirname "$queue")"

jq -cn --arg id "$sid" --arg cwd "$PWD" --arg title "${1:-}" \
  --arg at "$(date -u +%FT%TZ)" \
  '{id: $id, cwd: $cwd, title: $title, queued_at: $at}' >> "$queue"

echo "  ▸ queued for dissolve: $sid ($PWD) — the orrery worker extracts and commits (sweep backstop)"
