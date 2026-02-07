# Instructions for Claude Code

## Communication

- Assume expert-level context
- Concise, direct responses—minimize tokens, skip preamble/hedging

## Development Philosophies

### Chiastic Structure

For complex features: the journey inward is discovery, the journey outward is redesign.
Scaffold to the core, complete it, then revisit each outer layer—not to clean up, but to rebuild against what the center actually required.
Resist finalizing outer layers before inner ones have spoken.

## Standards

- Alpha-sort declarations where order is arbitrary (imports, object keys, union members, etc.)
- Assume auto-formatting via tooling—prioritize logic over style
- Edit over create—question if new files add value
- Inline single-use variables—compose at point of use to minimize bindings and cognitive overhead
- Prefer pragmatic solutions over site-wide configuration changes
- Prefer retrieval-led reasoning over pre-training-led reasoning
