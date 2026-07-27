#!/usr/bin/env bash
# delete-hard-v2.sh — v2's `/delete hard`: erase a conversation outright. No pointer, no
# buffer entry, no reconcile, zero tokens spent — the one ending that leaves nothing
# downstream. Unrecoverable by design.
#
# Erases, in this order (widest reach first, so a failure part-way still leaves the
# conversation harder to recover, never easier):
#   1. every buffered copy — an earlier ending, or a /clear snapshot, may have made one
#   2. every live transcript for the sid, across project dirs
#   3. the pending sidecar — notes taken at the time of attention die with their session
#
# Usage: delete-hard-v2.sh [session-id]
#
# Caveat, unfixable here: `~/.claude/history.jsonl` keeps one line per prompt (cwd + the
# prompt text) and is Claude Code's own file, not orrery's — this script does not touch
# it. A hard-deleted conversation's PROMPTS therefore survive there until that file is
# filtered by hand. (verified 2026-07-27 · planning/hook-probe-2026-07-27.md §5)
#
# A pointer already appended for this sid is NOT retracted: the queue is an append-only
# journal, and rewriting it is not this script's business. Reconcile will report that
# pointer `waiting` and then `lost` after 24 h — the correct outcome for a conversation
# whose transcript is gone, and it spends nothing.
#
# Live as of 2026-07-27: `/delete hard` runs this first, then the kill with `--hard` (the
# marker makes the CLI's final flush erase rather than archive).
set -u

# The v2 lifecycle primitives live with the dissolve skill (the buffer's write path is
# shared); resolved from THIS script's location so the two skill dirs can move together.
skills="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck source-path=SCRIPTDIR source=../../dissolve/scripts/lifecycle-v2.sh
. "$skills/dissolve/scripts/lifecycle-v2.sh"

sid="$(orrery_sid "${1:-}")"
if ! orrery_component "$sid"; then
  echo "  ✻ No usable session id — can't identify the conversation to erase." >&2
  exit 1
fi

erased=0

while IFS= read -r gz; do
  [ -n "$gz" ] || continue
  rm -f "$gz" && erased=$((erased + 1)) && echo "  ▸ erased buffer copy: $gz"
done <<< "$(orrery_buffer_copies "$sid")"

while IFS= read -r t; do
  [ -n "$t" ] || continue
  rm -f "$t" && erased=$((erased + 1)) && echo "  ▸ erased live transcript: $t"
done <<< "$(orrery_transcripts "$sid")"

sidecar="$ORRERY_PENDING_ROOT/$sid.jsonl"
if [ -f "$sidecar" ]; then
  rm -f "$sidecar" && erased=$((erased + 1)) && echo "  ▸ erased pending highlights: $sidecar"
fi

if [ "$erased" = 0 ]; then
  echo "  ✻ nothing found for $sid — already erased, or never written."
else
  echo "  ▸ $sid erased ($erased file(s)) — not buffered, not queued, not recoverable."
fi

echo "  ✻ ~/.claude/history.jsonl still holds this session's prompt lines (Claude Code's own file — filter by cwd to remove them)."
