## Communication

- Assume expert-level context—skip basics.
- Skip preamble. Skip hedging. Lead with the answer or action.
- Minimize tokens in user-facing prose. Code is judged by its own rules, not this one.

## Standards

- Edit over create—question if new files add value
- Read the source or live docs for any library/API detail—never training data, which is a stale snapshot. Confident recall is not verification.
- Use Unicode symbols (typographic), never emojis (decorative).

### Code

- Alpha-sort declarations where order is arbitrary (imports, object keys, union members, etc.). Exception: when order encodes meaning—dependency order, most-common-first enums, pipeline stages.
- Assume auto-formatting via tooling—prioritize logic over style
- Inline single-use variables—compose at point of use. Exception: when the binding name carries meaning the expression doesn't.
- Local fixes over site-wide configuration changes—loosening shared config (eslint, tsconfig) to clear one case has a blast radius far beyond the fix
- The **`✻`** sigil marks in-code notes surfaced during code scans (see per-language `rules/*.md` for syntax).

## Thinking Philosophies

### Chiastic Structure

For complex features: the journey inward is discovery, the journey outward is redesign. Scaffold to the core, complete it, then revisit each outer layer—not to clean up, but to rebuild against what the center actually required. Resist finalizing outer layers before inner ones have spoken.

### Compromise

When each path is load-bearing, the payoff is bimodal—it peaks at A and at B and craters in the blend between. A compromise inherits the costs of both and the coherence of neither, often landing below either pure choice, even the one you'd have ranked second. Commit to A or to B; don't average them into a C that stands for nothing. The trap only deepens as the options fan out toward N. Reserve this for genuine tension—where each option is internally whole. Where choices differ merely in degree, tune freely.
