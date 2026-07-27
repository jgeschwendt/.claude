#!/usr/bin/env bash
# enqueue-v2.sh — v2's ending path: append THIS session's POINTER to the dissolve queue,
# consume its transcript into the 90-day buffer, and kick a minor reconcile if the queue
# has grown past the threshold. `mix orrery.reconcile` extracts and routes from the
# BUFFER, never from a live transcript — observation and extraction are different reads.
#
# Usage: enqueue-v2.sh <full|salvage> [title]
#
#   full     — /dissolve: the conversation had value; extract broadly.
#   salvage  — /delete: the conversation had no value AS A WHOLE, but reconcile still runs
#              the narrow triage (instruction-shaped only, hard-delete-if-valueless).
#
# Pointer record (atlas D9): {id, cwd, title, queued_at, source, mode, highlights} — that
# field order is the record's documented shape, not alphabetical. `highlights` is adopted
# from this session's pending sidecar (notes written at the time of attention) and the
# sidecar is then deleted; the pointer is the durable home from the ending onward.
#
# Order is pointer → buffer → kick, deliberately. The two failures are not symmetric: a
# pointer whose buffer copy never arrived is VISIBLE (reconcile reports it `waiting`, then
# `lost` after 24 h), while a buffer entry no pointer names is invisible AND unprunable —
# `Buffer.prune/2` never drops an unextracted entry, and nothing will ever extract it.
#
# Env (all default to the real roots — see lifecycle-v2.sh):
#   ORRERY_BUFFER_KEEP_LIVE=1  copy instead of consume, leaving the live .jsonl in place —
#                              the SessionEnd(reason=clear) leg (see hooks/), and both CLI
#                              verbs, whose kill step owns that file's removal
#   ORRERY_POINTER_CWD         the pointer's cwd when the caller is not IN it (hooks)
#   ORRERY_POINTER_SOURCE      pointer provenance; defaults to the mode's verb
#
# Live as of 2026-07-27: called by /dissolve (full), /delete (salvage) and the /clear hook.
set -u

scripts="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source-path=SCRIPTDIR source=lifecycle-v2.sh
. "$scripts/lifecycle-v2.sh"

mode="${1:-}"
case "$mode" in
  full) default_source=dissolve ;;
  salvage) default_source=delete ;;
  *) echo "usage: enqueue-v2.sh <full|salvage> [title]" >&2; exit 2 ;;
esac

sid="$(orrery_sid)"
if ! orrery_component "$sid"; then
  echo "  ✻ No usable session id — can't identify the conversation to enqueue." >&2
  exit 1
fi

# ─── adopt the pending sidecar ────────────────────────────────────────────────
# Each sidecar line is `{at, body}`; the pointer adopts the bodies as plain strings,
# which is what the extract prompt renders (`Orrery.Prompts.one_line/1` inspects a
# non-binary highlight). Tolerant per line — `fromjson? // empty` drops a half-flushed
# trailing append instead of losing every note behind it — and tolerant of a bare JSON
# string, for a hand-written sidecar.
sidecar="$ORRERY_PENDING_ROOT/$sid.jsonl"
highlights='[]'
if [ -s "$sidecar" ]; then
  highlights="$(jq -R -s '
    split("\n")
    | map(fromjson? // empty)
    | map(if type == "object" then .body else . end)
    | map(select(type == "string" and . != ""))
  ' < "$sidecar")" || highlights='[]'
fi

# ─── the pointer ──────────────────────────────────────────────────────────────
mkdir -p "$(dirname "$ORRERY_QUEUE_PATH")"
jq -cn --arg id "$sid" --arg cwd "${ORRERY_POINTER_CWD:-$PWD}" --arg title "${2:-}" \
  --arg at "$(date -u +%FT%TZ)" --arg source "${ORRERY_POINTER_SOURCE:-$default_source}" \
  --arg mode "$mode" --argjson highlights "$highlights" \
  '{id: $id, cwd: $cwd, title: $title, queued_at: $at, source: $source, mode: $mode, highlights: $highlights}' \
  >> "$ORRERY_QUEUE_PATH" || {
  echo "  ✻ queue append failed ($ORRERY_QUEUE_PATH) — nothing buffered, nothing deleted." >&2
  exit 1
}

# Only now: the notes are durable in the pointer, so the pre-pointer home can go.
rm -f "$sidecar"

count="$(jq -r 'length' <<< "$highlights")"
echo "  ▸ queued: $sid · mode=$mode · highlights=$count"

# ─── the buffer write ─────────────────────────────────────────────────────────
# Write → verify → rm, per orrery_buffer_write. Copies of one sid share a buffer
# filename, so a second ending for the same session overwrites the first — id-keyed,
# exactly as `Buffer.read/1` resolves it.
buffered=0
while IFS= read -r t; do
  [ -n "$t" ] || continue
  if gz="$(orrery_buffer_write "$t" "$sid")"; then
    buffered=1
    if [ "${ORRERY_BUFFER_KEEP_LIVE:-0}" = 1 ]; then
      echo "  ▸ buffered (live transcript kept): $gz"
    else
      rm -f "$t"
      echo "  ▸ buffered, live transcript removed: $gz"
    fi
  else
    echo "  ✻ buffer write failed for $t — live transcript left exactly where it was." >&2
  fi
done <<< "$(orrery_transcripts "$sid")"

[ "$buffered" = 1 ] || echo "  ✻ no live transcript for $sid — the pointer stays queued (reconcile: waiting, then lost after 24 h)."

# ─── threshold trigger ────────────────────────────────────────────────────────
# Last, and never fatal: an ending must not fail because a reconcile could not start.
bash "$scripts/reconcile-kick.sh" || true
