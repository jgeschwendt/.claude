# claude() — wrapper around the claude CLI (sourced from ~/.zshrc).
#
# Fixes the /delete //dissolve end-of-session DX:
#   · exports CLAUDE_WRAPPER_STATE so the delete skill can signal it
#   · after the CLI exits, finalizes archive-on-exit markers deterministically
#     (gzip → ~/.orrery/archive, live .jsonl removed → un-resumable)
#   · if the session asked for a respawn (/delete or /dissolve), relaunches a fresh
#     claude in the same terminal as an EPHEMERAL FORK: pre-marked archive-on-exit,
#     so however it ends — even plain /exit — its transcript dissolves to the archive.
#     To keep a fork after all: rm ~/.orrery/archive/.archive-on-exit/$CLAUDE_CODE_SESSION_ID
#
# Sid injection: for plain interactive launches we pass --session-id ourselves so the
# wrapper knows exactly which transcript it owns. Resume-style, print, and subcommand
# invocations are left untouched. The delete skill also appends the sid it actually
# killed to $CLAUDE_WRAPPER_STATE/finalize (covers /clear, which rotates the sid
# mid-run) — the wrapper finalizes both its injected sid and every listed one.
claude() {
  emulate -L zsh
  local -a args
  args=("$@")
  local scripts="$HOME/.claude/skills/delete/scripts"
  local respawn=0 inject sid rc state a s

  while :; do
    state="$(mktemp -d)"
    sid=""
    inject=1
    for a in "${args[@]}"; do
      case "$a" in
        -c|--continue|--from-pr*|-h|--help|-p|--print|-r|--resume*|--session-id*|-v|--version) inject=0 ;;
        agents|auth|auto-mode|doctor|gateway|install|mcp|plugin|plugins|project|setup-token|ultrareview|update|upgrade) inject=0 ;;
      esac
    done

    if (( inject )); then
      sid="$(uuidgen | tr '[:upper:]' '[:lower:]')"
      if (( respawn )); then
        mkdir -p "$HOME/.orrery/archive/.archive-on-exit"
        : > "$HOME/.orrery/archive/.archive-on-exit/$sid" # ephemeral fork
      fi
      CLAUDE_WRAPPER_STATE="$state" command claude --session-id "$sid" "${args[@]}"
    else
      CLAUDE_WRAPPER_STATE="$state" command claude "${args[@]}"
    fi
    rc=$?

    [[ -n "$sid" ]] && bash "$scripts/archive-transcript.sh" --finalize "$sid"
    if [[ -f "$state/finalize" ]]; then
      while IFS= read -r s; do
        [[ -n "$s" && "$s" != "$sid" ]] && bash "$scripts/archive-transcript.sh" --finalize "$s"
      done < "$state/finalize"
    fi
    bash "$scripts/archive-transcript.sh" --sweep-stale

    if [[ -f "$state/respawn" ]]; then
      respawn=1
      args=() # forks always start blank
    else
      respawn=0
    fi
    rm -rf "$state"
    (( respawn )) || return $rc
  done
}
