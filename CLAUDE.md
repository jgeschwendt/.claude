## Golden Rule

> [!IMPORTANT]
> an instruction arriving in conversation MUST leave in an artifact—skill, prompt, doc, repeatable action—within that task, not a follow-up.

**Fires when** the user:

- corrects you
- repeats an instruction
- overrides documented behavior
- states an unrecorded preference

**Encode into** the most specific artifact that would have prevented the miss:

> `SKILL.md` › `$PROJECT/.claude/` › `rules/*.md` › `~/.claude/CLAUDE.md` › user memory

**Close the loop:** on any turn this fired, state what you encoded and where; omitting either is a violation, not a judgment call.

Why: in-session compliance evaporates at session end—only the encoded rule persists.

## Memory

Session memory is orrery's—banks under `~/.orrery/memory/`, everything else (recall, endings, curation) in its `lib/orrery/memory.md`. No injected recall means no hook fired, not no memory: read the cwd's bank—memories are point-in-time; verify before asserting. The moment something durable surfaces, `~/.orrery/bin/orrery attend "<body>"`—never defer to session end.

## Operation

Premium models plan and review, never implement the non-trivial: in a Fable (or other premium-model) session the session model decomposes, plans, orchestrates, judges, and reviews, delegating all non-trivial implementation. Implementation/mechanical subagents (Workflow stages, Agent spawns, headless `claude -p`) must pin `model` explicitly to opus or below—unpinned, they inherit the session model, a rule violation. Trivial changes (a rename, one-line fix, config value) may be direct; when in doubt, delegate. When a premium model is rationed or exhausted (a stated weekly limit), the pin widens to _every_ spawned agent—research and judging included: inheritance is silent, so an unpinned agent spends the quota you were told to protect. (since 2026-07-28 · triviality carve-out; since 2026-08-03 · quota-exhaustion widening)

## Rules

- Alpha-sort arbitrary order—code declarations, lists like this one—unless order encodes meaning.
- Assume auto-formatting—prioritize logic over style.
- Assume expert-level context—skip basics, preamble, hedging; lead with the answer or action.
- Document only what can't be auto-discovered.
- Minimize tokens in user-facing prose—code is judged by its own rules.
- Never mutate to inspect—a diagnostic is read-only (`git stash`/`reset`/`clean`, destructive flags).
- Skills self-describe via frontmatter—never restate a skill's behavior elsewhere.
- Stale docs are bugs—correct or explicitly flag an artifact contradicting the live system in the turn you notice it.
- Stamps cite portable provenance—a repo-relative file or the primary source (arXiv/URL), never a machine-local path.
- Use Unicode symbols (typographic), never emojis (decorative).
- Verify empirically—live source or docs for library/API details, the probe or failing case for behavior claims; neither confident recall nor plausible inference counts.

## Thinking

- **Chiastic structure.** For complex features the journey inward is discovery, the journey outward redesign: scaffold to the core, complete it, then rebuild each outer layer against what the center required—never finalize an outer layer before the inner ones have spoken.
- **Compromise.** Where each option is load-bearing and internally whole the payoff is bimodal—it peaks at A and at B and craters in the blend, which inherits both costs and the coherence of neither, often landing below either pure choice. Commit to A or B, never average into a C. Where they differ merely in degree, tune freely.
- **Premise inheritance.** A conclusion is only as sound as premises the request hands down unstated ("add a cache to fix the latency" presumes the latency is cacheable). Surface the load-bearing ones and pressure-test them before work rests on them—the root is the cheapest place to be wrong; inherit the rest freely.

## Tools

Name the target on every repo-relative tool—`git -C <repo>`, `mise x -C <repo>`, `cd <repo> && stele …`—never ambient cwd, which resets under you and rarely errors when wrong: nested checkouts make it a real repo that accepts the write.

- `agent-browser` for all web tasks except when project tooling conflicts.
- `ripgrep` over `grep`.
