# claude_ui

A Phoenix LiveView viewer for Claude Code conversations and memory banks, living
at the monorepo root `~/.claude`. An umbrella with one app (`@apps/web`), two namespaces:

- `@apps/web/lib/core` — domain: `Transcripts`, `Memory`, `Watcher`, `UserLog`, `Routines`
- `@apps/web/lib/web` — Phoenix LiveView: `ConversationsLive`, `MemoriesLive`, `UserLogLive`, `RoutinesLive`

## Start

```sh
mise install                    # pinned erlang/elixir (fresh machine)
mise exec -- mix setup          # deps + asset tooling
mise exec -- mix phx.server     # → http://localhost:4000
```
