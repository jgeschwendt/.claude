#!/usr/bin/env bash
# session-end-clear.sh — SessionEnd hook, `/clear` leg only. Reads the hook payload on
# stdin; when (and only when) `reason == "clear"`, it copies the just-ended conversation
# into the buffer and mints a `mode: full` pointer, so a context the user cleared is
# routed like a /dissolve instead of being lost.
#
# settings.json wiring (installed 2026-07-27):
#   "SessionEnd": [{"hooks": [{"type": "command",
#     "command": "bash ~/.claude/skills/dissolve/hooks/session-end-clear.sh"}]}]
#
# `reason` is matched against an allow-list of ONE. The field has six values —
# clear · resume · logout · prompt_input_exit · other · bypass_permissions_disabled — so
# "not prompt_input_exit" would route crash-shaped endings (`other`) and logouts as if the
# user had asked for it. Ruling ⑧: /exit routes nothing.
# (verified 2026-07-27 · live hook probe, 2026-07-27; see orrery git history §1, §4 R2)
#
# COPY, not consume: ORRERY_BUFFER_KEEP_LIVE=1 leaves the live `.jsonl` in place. The
# probe found that /clear retires the session id and mints a NEW transcript file, so a
# destructive read → gzip → rm was verified safe here (§3.1, §3.5) — keeping the copy is
# therefore a product choice (the pre-clear conversation stays resumable via `claude -r`),
# not a mechanical constraint. The cost of that choice: nothing in orrery ever reaps that
# live file afterwards.
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

[ "$(field reason)" = clear ] || exit 0

sid="$(field session_id)"
orrery_component "$sid" || exit 0

cwd="$(field cwd)"
log="$ORRERY_ROUTINES_DIR/hooks-v2.log"
mkdir -p "$ORRERY_ROUTINES_DIR"

# stdout is invisible outside `claude --debug`, so the hook's own trail goes to a file —
# a dark hook that fails silently is indistinguishable from one that never fired.
{
  printf '%s session-end-clear: sid=%s cwd=%s\n' "$(date -u +%FT%TZ)" "$sid" "$cwd"

  CLAUDE_SESSION_ID="$sid" \
    ORRERY_BUFFER_KEEP_LIVE=1 \
    ORRERY_POINTER_CWD="${cwd:-$PWD}" \
    ORRERY_POINTER_SOURCE=session_end_clear \
    bash "$scripts/enqueue-v2.sh" full "cleared context · $(basename "${cwd:-unknown}") · $(date -u +%F)"
} >> "$log" 2>&1

exit 0
