#!/usr/bin/env bash
# attend-v2.sh — write at the time of attention: append ONE highlight to this session's
# pending sidecar (`<pending root>/<sid>.jsonl`). The sidecar is the durable PRE-pointer
# home for notes taken mid-session (atlas D9); the ending verb adopts them into the queue
# pointer's `highlights[]` and deletes the sidecar, and the extract prompt then treats
# each one as a pre-extracted candidate — a hint, not a quota, and not a lowered bar.
#
# Successor to appending to `.staging.json`: a note here is never committed on its own, it
# only rides the conversation it came from. A session that /exit's leaves its sidecar in
# place, awaiting adoption by whichever ending verb eventually routes that session.
#
# Usage: attend-v2.sh <highlight body> [session-id]
#
# One line per call, `{at, body}`, append-only — no rewrite, no dedupe: two calls that say
# the same thing cost the extractor one duplicate, while a rewrite risks losing a note.
#
# Live as of 2026-07-27: CLAUDE.md § Memory names this sidecar as the write-at-attention
# home (this script, or a plain append — the hook-free path).
set -u

scripts="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source-path=SCRIPTDIR source=lifecycle-v2.sh
. "$scripts/lifecycle-v2.sh"

body="${1:-}"
if [ -z "$body" ]; then
  echo "usage: attend-v2.sh <highlight body> [session-id]" >&2
  exit 2
fi

sid="$(orrery_sid "${2:-}")"
if ! orrery_component "$sid"; then
  echo "  ✻ No usable session id — a highlight with no session has nothing to ride." >&2
  exit 1
fi

mkdir -p "$ORRERY_PENDING_ROOT"
jq -cn --arg at "$(date -u +%FT%TZ)" --arg body "$body" '{at: $at, body: $body}' \
  >> "$ORRERY_PENDING_ROOT/$sid.jsonl" || {
  echo "  ✻ sidecar append failed ($ORRERY_PENDING_ROOT/$sid.jsonl) — the note was NOT recorded." >&2
  exit 1
}

echo "  ▸ highlight noted for $sid ($(wc -l < "$ORRERY_PENDING_ROOT/$sid.jsonl" | tr -d ' ') pending)"
