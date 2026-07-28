#!/usr/bin/env bash
# post-compact-snapshot.sh — PostCompact hook, MANUAL `/compact` only: the SNAPSHOT half of
# family B's compact leg. A manual compaction discards the pre-compact conversation from
# context while the session itself continues; this hook copies that discarded prefix into
# the buffer and mints a `mode: full` pointer for it, so the part of the conversation the
# user just dropped is routed like a /dissolve instead of being lost.
#
# settings.json wiring (installed 2026-07-27). The matcher is load-bearing:
#   "PostCompact": [{"matcher": "manual", "hooks": [{"type": "command",
#     "command": "bash ~/.claude/skills/dissolve/hooks/post-compact-snapshot.sh"}]}]
#
# Why PostCompact and not PreCompact (live hook probe, 2026-07-27; see orrery git history §3.6, §4 — the
# probe amended atlas D8 on exactly this point): PreCompact fires SPECULATIVELY. It fires
# when there is too little to compact, it fires again on the auto path every turn, and in
# neither case does a compaction follow — so a snapshot taken there mints a pointer for a
# compaction that may never happen. PostCompact fires once, only when a compaction actually
# landed. PreCompact keeps the gate (pre-compact-confirm.sh); this keeps the snapshot.
#
# COPY, never consume: `/compact` does NOT retire the session id — the same id and the same
# transcript file span the boundary and the file keeps growing (§3.2). So `rm` is out here,
# unlike the /clear leg, and the buffered entry gets a DERIVED id (`<sid>-compact-<stamp>`)
# rather than the sid: the session is still running and its own ending will mint a pointer
# under the bare sid. Sharing one id would collide in the buffer AND in the ledger, where a
# permanent outcome for the snapshot would make the later real ending look already handled.
#
# Highlights are deliberately NOT adopted: the pending sidecar belongs to the session, and
# this session has not ended. Whichever verb eventually ends it adopts the notes then.
#
# Hooks are AWAITED by the CLI (§3.4) — everything here is filesystem work, and the only
# slow thing downstream (a reconcile) is backgrounded by reconcile-kick.sh.
set -u

hooks="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
scripts="$hooks/../scripts"
# shellcheck source-path=SCRIPTDIR source=../scripts/lifecycle-v2.sh
. "$scripts/lifecycle-v2.sh"

payload="$(cat)"
field() { jq -r --arg key "$1" '.[$key] // ""' <<< "$payload" 2>/dev/null; }

# `trigger` ∈ {manual, auto}. Auto-compact is never an ending (it is context management the
# user did not ask for), so it snapshots nothing — the same allow-list-of-one discipline the
# other two v2 hooks use.
[ "$(field trigger)" = manual ] || exit 0

sid="$(field session_id)"
orrery_component "$sid" || exit 0

cwd="$(field cwd)"
log="$ORRERY_ROUTINES_DIR/hooks-v2.log"
mkdir -p "$ORRERY_ROUTINES_DIR"

# stdout is invisible outside `claude --debug`, so the hook's own trail goes to a file —
# a dark hook that fails silently is indistinguishable from one that never fired.
{
  printf '%s post-compact-snapshot: sid=%s cwd=%s\n' "$(date -u +%FT%TZ)" "$sid" "$cwd"

  # ─── the sentinel ───────────────────────────────────────────────────────────
  # Hygiene, not authorization: the gate's sentinel is one-shot permission for ONE manual
  # compaction, and pre-compact-confirm.sh normally consumes it on the pass it allows. One
  # surviving here means the gate did not run for this compaction (not installed, or an
  # ending verb dropped the sentinel and nothing consumed it) — leaving it would silently
  # pre-authorize the NEXT /compact, skipping the gate for a conversation nobody routed.
  sentinel="$ORRERY_COMPACT_OK_DIR/$sid"
  if [ -f "$sentinel" ]; then
    rm -f "$sentinel"
    echo "  ▸ consumed the compact-ok sentinel (the gate had not)"
  fi

  # ─── the pre-compact prefix ─────────────────────────────────────────────────
  transcript="$(field transcript_path)"
  [ -f "$transcript" ] || transcript="$(orrery_transcripts "$sid" | head -1)"
  if [ ! -f "$transcript" ]; then
    echo "  ✻ no readable transcript for $sid — nothing to snapshot." >&2
    exit 0
  fi

  # The compaction is recorded IN-BAND as a `system`/`subtype: compact_boundary` line and
  # the pre-compact messages stay in the file (§3.2), so the prefix is deterministic: every
  # line before the LAST boundary. Read per line with `fromjson?` so one half-written line
  # costs that line rather than the whole read, and streamed (`input_line_number`) rather
  # than slurped — a long conversation's transcript is megabytes.
  boundary="$(jq -R -r '
    fromjson?
    | select(.type == "system" and .subtype == "compact_boundary")
    | input_line_number
  ' < "$transcript" 2>/dev/null | tail -1)"
  case "$boundary" in '' | *[!0-9]*) boundary=0 ;; esac

  snap="$(mktemp "${TMPDIR:-/tmp}/orrery-post-compact.XXXXXX")" || {
    echo "  ✻ could not open a scratch file — nothing snapshotted." >&2
    exit 0
  }

  # No boundary line means this hook beat the CLI's write of it (unverified — the probe read
  # the marker after the fact, never at hook time). The whole current file is then the safe
  # fallback: it is a SUPERSET of the pre-compact prefix, same session, so extraction sees
  # everything it would have seen plus a little of what came after.
  if [ "$boundary" -gt 1 ]; then
    head -n "$((boundary - 1))" "$transcript" > "$snap"
    extent="prefix/$((boundary - 1))L"
  else
    cat "$transcript" > "$snap"
    extent="whole-file/$(wc -l < "$transcript" | tr -d ' ')L"
  fi

  # ─── the pointer, then the buffer copy ──────────────────────────────────────
  # Same order and the same asymmetry enqueue-v2.sh documents: a pointer whose buffer copy
  # never arrived is VISIBLE (reconcile reports it `waiting`), a buffer entry no pointer
  # names is invisible AND unprunable. The pointer record is built here rather than by
  # calling enqueue-v2.sh because that script owns ONE shape this leg cannot use — it
  # buffers by globbing the live `<sid>.jsonl`, and this leg buffers a derived id's prefix
  # of a file that must survive. Field order below is the record's documented shape (atlas
  # D9), not alphabetical; keep it in step with enqueue-v2.sh.
  snapid="$sid-compact-$(date -u +%Y%m%dT%H%M%SZ)"
  if ! orrery_component "$snapid"; then
    echo "  ✻ derived id is not a usable filename ($snapid) — nothing snapshotted." >&2
    rm -f "$snap"
    exit 0
  fi

  mkdir -p "$(dirname "$ORRERY_QUEUE_PATH")"
  jq -cn --arg id "$snapid" --arg cwd "${cwd:-$PWD}" \
    --arg title "pre-compact snapshot · $(basename "${cwd:-unknown}") · $(date -u +%F)" \
    --arg at "$(date -u +%FT%TZ)" --arg source post_compact_manual \
    '{id: $id, cwd: $cwd, title: $title, queued_at: $at, source: $source, mode: "full", highlights: []}' \
    >> "$ORRERY_QUEUE_PATH" || {
    echo "  ✻ queue append failed ($ORRERY_QUEUE_PATH) — nothing buffered." >&2
    rm -f "$snap"
    exit 0
  }

  echo "  ▸ queued: $snapid · mode=full · $extent"

  if gz="$(orrery_buffer_write "$snap" "$snapid")"; then
    echo "  ▸ buffered (live transcript untouched — the session continues): $gz"
  else
    echo "  ✻ buffer write failed — the pointer stays queued (reconcile: waiting)." >&2
  fi
  rm -f "$snap"

  # ─── threshold trigger ──────────────────────────────────────────────────────
  # Last, and never fatal: a compaction must not fail because a reconcile could not start.
  bash "$scripts/reconcile-kick.sh" || true
} >> "$log" 2>&1

exit 0
