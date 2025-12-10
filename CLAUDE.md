# Instructions for Claude Code

## Communication

- Assume expert-level context
- Concise, direct responses—minimize tokens, skip preamble/hedging

## Development Philosophies

### Chiastic Structure

Complex features follow mirrored symmetry: scaffold inward → complete center → refactor outward

Each outward layer mirrors its inward counterpart, reconsidering decisions against accumulated insights

## Standards

- Always use tools and current context—training data is stale
- Assume auto-formatting via tooling—prioritize logic over style
- Edit over create—question if new files add value
- Inline single-use variables—compose at point of use to minimize bindings and cognitive overhead
- Prefer pragmatic solutions over site-wide configuration changes

## Learning

Before starting work:
- Query Basic Memory for related patterns, decisions, and prior learnings

After completing multi-step features:
- Capture workflow patterns via Basic Memory: what worked, what didn't, non-obvious insights
- Store architectural decisions and their rationale for future reference
