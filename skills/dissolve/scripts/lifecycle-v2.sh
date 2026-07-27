# shellcheck shell=bash
# lifecycle-v2.sh — the shell twin of `Orrery.Paths` (orrery `lib/orrery/paths.ex`) plus
# the three primitives every v2 ending verb shares: the session id, the live transcripts
# a session owns, and the gzip-ordered buffer write. Sourced, never executed.
#
# One home for the roots for the same two reasons Paths gives: a smoke test overrides
# four variables and can then touch nothing real, and v2 relocates roots (buffer, pending
# sidecars) that `rg`-ing five scripts is not a migration plan for. Roots that live INSIDE
# another root — the sidecars, the queue, the ledger — hang off that parent's RESOLVED
# value, so overriding ORRERY_MEMORY_ROOT alone can never leave a sidecar pointing at the
# live bank while the rest of the run is sandboxed.
#
# Live as of 2026-07-27: sourced by the /dissolve and /delete verbs and by all three hooks.

# ─── roots ────────────────────────────────────────────────────────────────────
ORRERY_BUFFER_ROOT="${ORRERY_BUFFER_ROOT:-$HOME/.orrery/buffer}"
ORRERY_MEMORY_ROOT="${ORRERY_MEMORY_ROOT:-$HOME/.orrery/memory}"
ORRERY_PROJECTS_DIR="${ORRERY_PROJECTS_DIR:-$HOME/.claude/projects}"
ORRERY_ROUTINES_DIR="${ORRERY_ROUTINES_DIR:-$HOME/.orrery/routines}"

# derived — resolved parents, per the rule above
ORRERY_COMPACT_OK_DIR="${ORRERY_COMPACT_OK_DIR:-$ORRERY_MEMORY_ROOT/.compact-ok}"
ORRERY_LEDGER_PATH="${ORRERY_LEDGER_PATH:-$ORRERY_MEMORY_ROOT/.sweep.jsonl}"
ORRERY_PENDING_ROOT="${ORRERY_PENDING_ROOT:-$ORRERY_MEMORY_ROOT/.pending}"
ORRERY_QUEUE_PATH="${ORRERY_QUEUE_PATH:-$ORRERY_MEMORY_ROOT/.dissolve-queue.jsonl}"

# ─── session identity ─────────────────────────────────────────────────────────
# $1 (an explicit id, for hooks and for a dead session) wins; otherwise the live env.
# CLAUDE_CODE_SESSION_ID is the variable Claude Code 2.1.220 actually exports (verified
# live 2026-07-27); CLAUDE_SESSION_ID is read first because the v2 brief names it and a
# future rename in that direction must not break the verbs.
orrery_sid() {
  printf '%s' "${1:-${CLAUDE_SESSION_ID:-${CLAUDE_CODE_SESSION_ID:-}}}"
}

# A sid reaches these scripts from the environment or a hook payload and becomes a
# FILENAME (buffer entry, pending sidecar, sentinel) — the same test `Store.component?/1`
# applies before `Orrery.Buffer` will write one.
orrery_component() { # $1=candidate
  case "${1:-}" in
    '' | '.' | '..') return 1 ;;
    */*) return 1 ;;
    *) return 0 ;;
  esac
}

# ─── live transcripts ─────────────────────────────────────────────────────────
# One path per line, nothing when the session has none. Globbed across project dirs
# because a sid is unique but its project dir is not knowable from the sid alone.
orrery_transcripts() { # $1=sid
  local t
  shopt -s nullglob
  for t in "$ORRERY_PROJECTS_DIR"/*/"$1".jsonl; do printf '%s\n' "$t"; done
  shopt -u nullglob
}

# ─── the buffer write ─────────────────────────────────────────────────────────
# `Orrery.Buffer`'s contract, in shell: gzip-write into today's dated dir as
# `<sid>.jsonl.gz`, and VERIFY the copy before the caller is allowed to remove anything.
# Never a rename — a `mv` cannot produce a `.jsonl.gz`, and it collapses the two steps
# that make a crash mid-write survivable. The dated dir is UTC because
# `Buffer.write!/2` uses `Date.utc_today/0`; a local-time dir would age differently.
#
# Returns non-zero (and leaves no half copy) on any failure, so the ordering rule the
# callers depend on — write, verify, only then `rm` the live file — holds by construction.
orrery_buffer_write() { # $1=transcript path, $2=sid
  local dir gz
  dir="$ORRERY_BUFFER_ROOT/$(date -u +%F)"
  gz="$dir/$2.jsonl.gz"
  mkdir -p "$dir" || return 1
  if gzip -c "$1" > "$gz" && gzip -t "$gz"; then
    printf '%s\n' "$gz"
    return 0
  fi
  rm -f "$gz"
  return 1
}

# Every buffered copy of a sid, oldest first (dated dir names sort chronologically).
orrery_buffer_copies() { # $1=sid
  local gz
  shopt -s nullglob
  for gz in "$ORRERY_BUFFER_ROOT"/*/"$1".jsonl.gz; do printf '%s\n' "$gz"; done
  shopt -u nullglob
}
