## Communication

- Assume expert-level context—skip basics (git fundamentals, standard library idioms, common design patterns). If a term has a standard meaning in this field, do not define it.
- Skip preamble. Skip hedging. Lead with the answer or action.
- Minimize tokens in user-facing text. Code length is judged by the code's own rules, not this one.

## Development Philosophies

### Chiastic Structure

For complex features: the journey inward is discovery, the journey outward is redesign.
Scaffold to the core, complete it, then revisit each outer layer—not to clean up, but to rebuild against what the center actually required.
Resist finalizing outer layers before inner ones have spoken.

## Standards

- Alpha-sort declarations where order is arbitrary (imports, object keys, union members, etc.). Exception: when order encodes semantics—dependency order, most-common-first enums, pipeline stages, or any case where rearranging changes meaning.
- Assume auto-formatting via tooling—prioritize logic over style
- Edit over create—question if new files add value
- Inline single-use variables—compose at point of use. Exception: when the binding name carries meaning the expression doesn't (a variable name that documents intent the code would otherwise obscure).
- Prefer pragmatic solutions over site-wide configuration changes
- Prefer retrieval-led reasoning over pre-training-led reasoning. When uncertain about a library API, a recent change, or a project-specific convention, Read the source or WebFetch the docs—do not guess from memory.
