## Golden Rule

IMPORTANT: An instruction that arrives in conversation MUST leave in an artifact. When told something that conflicts with—or is absent from—a skill, prompt, doc, rule file, or repeatable action, encoding it is part of the task, not a follow-up.

- **Fires when:** the user corrects you, repeats an instruction, overrides documented behavior, or states a preference no artifact records. Exception: instructions the user marks one-off ("just this once").
- **Encode into** the most specific artifact that would have prevented the miss: the skill's `SKILL.md` › the repo's `.claude/` › `rules/*.md` › this file › user memory.
- **Close the loop:** before ending any turn where this fired, state what you encoded and where. Ending such a turn with no encoding and no stated reason is a rule violation, not a judgment call.

Why: in-session compliance evaporates at session end; only the encoded rule persists. A correction you don't encode is a correction the user repeats forever.

## Communication

- Assume expert-level context—skip basics.
- Skip preamble. Skip hedging. Lead with the answer or action.
- Minimize tokens in user-facing prose. Code is judged by its own rules, not this one.

## Memory

Committed session memory lives in per-directory banks under `~/.orrery/memory/<bank>/` (bank = cwd with every non-alphanumeric character → `-`). Pipeline mechanics (sweep, judge, dissolve queue, the dream) are documented in orrery's `lib/orrery/memory.md` (github.com/jgeschwendt/orrery, cloned locally) and the `/dissolve`·`/delete` skills—read those when needed; this file deliberately doesn't restate them, they change faster than it does.

A session owes the system three behaviors:

- **Recall is injected:** a SessionStart hook feeds the cwd's bank plus ancestor banks into every session. Hook-free fallback (some work sessions): read the matching bank's `MEMORY.md` yourself (case-insensitive cwd match). Either way, memories are point-in-time observations—verify before asserting.
- **Write at the time of attention:** the moment a durable memory surfaces, append `{bank, body, description, name, recall, replaces, source, type}` to `~/.orrery/memory/.staging.json`, replacing any entry with the same `bank`+`name`. Never defer to session end—not every ending extracts.
- **Never hand-edit** committed bank files or `MEMORY.md`; every write flows through the pipeline, and the dashboard is a viewer/editor, not a gate. Durable _instructions_ still route through the Golden Rule—artifacts for rules, memory for observations. Don't stage what belongs in a SKILL.md.

## Rules

- Edit over create—question if new files add value
- Hook-based designs need a hook-free fallback—hooks are disabled in some sessions
- House rules (`rules/*.md`) govern code authored for this machine—in a repo with its own convention (work, third-party), the surrounding code wins.
- Premium models never implement—in a Fable (or other premium-model) session, implementation/mechanical subagents (Workflow stages, Agent spawns, headless `claude -p`) must pin `model` explicitly to opus or below; agents inherit the session model by default, so an unpinned agent is a rule violation. The session model decomposes, orchestrates, judges, and reviews—it never types the code.
- Re-read before you edit—the user edits files alongside you mid-task; your last read may be stale.
- Scripts under `~/.claude` are bash (+jq)—never python
- Skills self-describe via frontmatter—never restate a skill's behavior in this file or another skill; document only what can't be auto-discovered.
- Stale docs are bugs—an artifact that contradicts the live system gets corrected (or explicitly flagged) in the turn you notice it, never silently routed around.
- Stamps cite portable provenance—a repo-relative file or the primary source (arXiv/URL), never a machine-local path: `~/.orrery` data and gigaresearch workspaces exist only on the machine that wrote them.
- Use Unicode symbols (typographic), never emojis (decorative).
- Verify empirically—for library/API details read the live source or docs (training data is a stale snapshot); for behavior claims run the probe or the failing case. Confident recall is not verification; neither is plausible inference.

### Code

- Alpha-sort declarations where order is arbitrary (imports, object keys, union members, etc.). Exception: when order encodes meaning—dependency order, most-common-first enums, pipeline stages.
- Assume auto-formatting via tooling—prioritize logic over style
- Extract magic numbers into named `UPPER_CASE` constants—`-1`, `0`, `1`, `2` exempt; the name carries what the bare literal doesn't. (since 2026-07-19 · @jlg/eslint no-magic-numbers; ra's Rust consts)
- Inline single-use variables—compose at point of use. Exception: when the binding name carries meaning the expression doesn't.
- Local fixes over site-wide configuration changes—loosening shared config (eslint, tsconfig) to clear one case has a blast radius far beyond the fix
- The **`✻`** sigil marks in-code notes surfaced during code scans—one plain line comment (`# ✻ note` / `// ✻ note`); update or remove it the moment its subject changes.

## Thinking Philosophies

### Chiastic Structure

For complex features: the journey inward is discovery, the journey outward is redesign. Scaffold to the core, complete it, then revisit each outer layer—not to clean up, but to rebuild against what the center actually required. Resist finalizing outer layers before inner ones have spoken.

### Compromise

When each path is load-bearing, the payoff is bimodal—it peaks at A and at B and craters in the blend between. A compromise inherits the costs of both and the coherence of neither, often landing below either pure choice, even the one you'd have ranked second. Commit to A or to B; don't average them into a C that stands for nothing. The trap only deepens as the options fan out toward N. Reserve this for genuine tension—where each option is internally whole. Where choices differ merely in degree, tune freely.

### Premise Inheritance

A conclusion can be no sounder than the premise beneath it—and premises are rarely chosen so much as inherited, handed down unstated inside the request itself ('add a cache to fix the latency' presumes the latency is cacheable). A false one doesn't announce itself; it propagates, and everything built above it is wasted in proportion to how far you built before catching it—the root is the cheapest place to be wrong. Surface the load-bearing premises and pressure-test them before committing to the work that rests on them. Reserve the scrutiny for the assumptions the whole structure stands on; the rest you may inherit freely.

## Tools

- `agent-browser` is your web browser—do all web tasks with it. Exception: a skill that prescribes its own web tooling wins (its SKILL.md governs).
- `ripgrep` over `grep`
