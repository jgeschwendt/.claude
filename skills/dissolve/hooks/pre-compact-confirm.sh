#!/usr/bin/env bash
# pre-compact-confirm.sh — PreCompact hook, MANUAL `/compact` only: the confirm gate
# (atlas D6). A manual compaction discards the pre-compact conversation from context; this
# gate refuses the first attempt with the two routes named, and lets the next one through.
#
# settings.json wiring (installed 2026-07-27). The matcher is load-bearing:
#   "PreCompact": [{"matcher": "manual", "hooks": [{"type": "command",
#     "command": "bash ~/.claude/skills/dissolve/hooks/pre-compact-confirm.sh"}]}]
#
# Three probe findings shape this script (planning/hook-probe-2026-07-27.md, 2026-07-27):
#
#   * `exit 2` genuinely BLOCKS compaction, the session survives, and this script's stderr
#     reaches the user verbatim (§3.4). A hook has no tty, so it cannot ASK — the
#     achievable gate is deny-with-instructions, and the user's next action is the answer.
#   * `matcher` filters on `trigger` exactly, with no cross-firing (§3.3) — and the
#     `trigger` check below is the second belt: an `exit 2` on the AUTO path would refuse
#     compaction at context exhaustion, and since the auto event repeats every turn (§3.6)
#     that wedges the session rather than inconveniencing it (§4 R1). Auto is a no-op here,
#     always — auto-compact is never an ending.
#   * PreCompact fires SPECULATIVELY: it also fires when there is too little to compact,
#     and no compaction follows (§3.6). So this script never snapshots and never mints a
#     pointer — it only decides. The snapshot belongs on `PostCompact(trigger=manual)`,
#     which fires once and only when a compaction actually landed (§4) — that leg is
#     `post-compact-snapshot.sh`, wired beside this one.
#
# The sentinel (`<memory root>/.compact-ok/<sid>`) is what makes the gate pass-on-retry:
# this script drops it when it denies, and consumes it when it finds one. An ending verb
# may also drop it, so a conversation that was just routed compacts without a detour.
set -u

hooks="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source-path=SCRIPTDIR source=../scripts/lifecycle-v2.sh
. "$hooks/../scripts/lifecycle-v2.sh"

payload="$(cat)"
field() { jq -r --arg key "$1" '.[$key] // ""' <<< "$payload" 2>/dev/null; }

[ "$(field trigger)" = manual ] || exit 0

sid="$(field session_id)"
# An unusable sid cannot key a sentinel, so the gate could never be satisfied — allow.
orrery_component "$sid" || exit 0

sentinel="$ORRERY_COMPACT_OK_DIR/$sid"
if [ -f "$sentinel" ]; then
  rm -f "$sentinel"
  exit 0
fi

mkdir -p "$ORRERY_COMPACT_OK_DIR" && : > "$sentinel"

cat >&2 <<'MSG'
orrery: this conversation has not been routed, and compacting discards it from context.
Route it first — /dissolve (extract it into memory) or /delete (salvage triage only) —
then start fresh. To compact anyway, re-issue /compact: this gate now allows one pass.
MSG
exit 2
