#!/usr/bin/env bash
# reconcile-kick.sh — the queue-depth trigger: count pending pointers and, at or past the
# threshold, start a MINOR reconcile in the background (extract · route · index regen).
# Called last by enqueue-v2.sh, and safe to call by hand.
#
# Pending is derived exactly as `Orrery.Memory.Pipeline.Runner.pending/1` derives it, in
# jq: the append-only queue's ids, deduped, minus every id whose NEWEST ledger outcome is
# permanent (`dissolved|lost|staged|trivial`). `error` is not permanent — an entry that
# failed extraction is still pending and still counts. Nothing is ever rewritten here:
# this script only reads.
#
# Double-firing is harmless by design: `Reconcile.run/1` takes the pipeline lock and a
# second pass exits 1 rather than running concurrently, so a burst of endings costs at
# most one skipped launch.
#
# Env:
#   ORRERY_KICK_DRYRUN=1        print the decision and the command, run nothing
#   ORRERY_KICK_THRESHOLD=<n>   queue depth that triggers a kick (default 10)
#   ORRERY_MISE=<path>          mise binary (a hook/launchd context has no PATH)
#   ORRERY_REPO=<path>          the orrery clone that owns `mix orrery.reconcile`
#
# Live as of 2026-07-27: fires from enqueue-v2.sh at every ending, and by hand.
set -u

THRESHOLD_DEFAULT=10

scripts="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source-path=SCRIPTDIR source=lifecycle-v2.sh
. "$scripts/lifecycle-v2.sh"

# `--rawfile` needs the file to exist; an absent queue or ledger is a legitimate state
# (fresh machine), and reads as empty rather than as an error.
queue_file="$ORRERY_QUEUE_PATH"
ledger_file="$ORRERY_LEDGER_PATH"
[ -f "$queue_file" ] || queue_file=/dev/null
[ -f "$ledger_file" ] || ledger_file=/dev/null

# `fromjson? // empty` per line is the tolerance the queue needs: it is written by shell
# appends with no lock, so a half-flushed trailing line must cost one entry, not the file.
# The newest outcome per id comes from a `reduce` in FILE order (last write wins) rather
# than from `group_by | .[-1]`, which would lean on jq's sort being stable.
pending="$(jq -n --rawfile queue "$queue_file" --rawfile ledger "$ledger_file" '
  def entries: split("\n") | map(fromjson? // empty);
  ["dissolved", "lost", "staged", "trivial"] as $permanent
  | (reduce ($ledger | entries)[] as $line ({};
      if ($line.id | type) == "string" and ($line.outcome | type) == "string"
      then .[$line.id] = $line.outcome
      else . end)) as $newest
  | ($queue | entries | map(.id) | map(select(type == "string" and . != "")) | unique)
  | map(select(($newest[.] // "") as $outcome | ($permanent | index($outcome)) == null))
  | length
')" || {
  echo "  ✻ reconcile-kick: could not read the queue/ledger — no kick." >&2
  exit 0
}

threshold="${ORRERY_KICK_THRESHOLD:-$THRESHOLD_DEFAULT}"
if [ "$pending" -lt "$threshold" ]; then
  echo "  ▸ reconcile-kick: pending=$pending (threshold $threshold) — no kick"
  exit 0
fi

repo="${ORRERY_REPO:-$HOME/GitHub/jgeschwendt/orrery}"
mise="${ORRERY_MISE:-$HOME/.local/bin/mise}"
[ -x "$mise" ] || mise="$(command -v mise || true)"
log="$ORRERY_ROUTINES_DIR/reconcile-kick.log"

if [ "${ORRERY_KICK_DRYRUN:-0}" = 1 ]; then
  echo "  ▸ reconcile-kick: pending=$pending ≥ $threshold — would run (dry run):"
  echo "      cd $repo && $mise exec -- mix orrery.reconcile --minor  >> $log"
  exit 0
fi

if [ ! -d "$repo" ] || [ -z "$mise" ]; then
  echo "  ✻ reconcile-kick: pending=$pending ≥ $threshold but no runnable clone (repo=$repo mise=${mise:-none}) — no kick." >&2
  exit 0
fi

mkdir -p "$ORRERY_ROUTINES_DIR"
printf '%s reconcile-kick: pending=%s ≥ %s — starting minor reconcile\n' \
  "$(date -u +%FT%TZ)" "$pending" "$threshold" >> "$log"

# Backgrounded and detached: an ending must never wait on a reconcile (a SessionEnd hook
# is AWAITED by the CLI — verified 2026-07-27, planning/hook-probe-2026-07-27.md §3.4).
# The single quotes are the point: repo and mise arrive as ARGUMENTS to the child shell,
# so neither a space nor a quote in either path can reshape the command it runs.
# shellcheck disable=SC2016
nohup bash -c 'cd "$1" && exec "$2" exec -- mix orrery.reconcile --minor' _ "$repo" "$mise" \
  >> "$log" 2>&1 &
disown

echo "  ▸ reconcile-kick: pending=$pending ≥ $threshold — minor reconcile started (log: $log)"
