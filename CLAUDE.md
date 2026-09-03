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

Session memory is sandman's (`~/.sandman`; recall is injected at session start). The moment something durable surfaces, `~/.local/bin/sandman remember "<body>"`—never defer to session end.

## Operation

Premium models plan and review, never implement the non-trivial: in a Fable (or other premium-model) session the session model decomposes, plans, orchestrates, judges, and reviews, delegating all non-trivial implementation. Implementation/mechanical subagents (Workflow stages, Agent spawns, headless `claude -p`) must pin `model` explicitly to opus or below—unpinned, they inherit the session model, a rule violation. Trivial changes (a rename, one-line fix, config value, a small edit the session has already fully specified — one function plus its tests) may be direct; when in doubt, delegate. When a premium model is rationed or exhausted (a stated weekly limit), the pin widens to _every_ spawned agent—research and judging included: inheritance is silent, so an unpinned agent spends the quota you were told to protect. (since 2026-07-28 · triviality carve-out; since 2026-08-03 · quota-exhaustion widening)

## Rules

- Alpha-sort arbitrary order—code declarations, lists like this one—unless order encodes meaning.
- Assume auto-formatting—prioritize logic over style.
- Assume expert-level context—skip basics, preamble, hedging; lead with the answer or action.
- Document only what can't be auto-discovered.
- Minimize tokens in user-facing prose—code is judged by its own rules.
- Never mutate to inspect—a diagnostic is read-only (`git stash`/`reset`/`clean`/`checkout --`/`restore`, destructive flags). Undo your own botched edit by re-editing, never by tree-discard: `git checkout -- <path>` throws away _every_ uncommitted change to the path, co-resident work included. (since 2026-08-31 · bridge scene: a subagent's checkout-- undo wiped another feature's uncommitted elements)
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

- `agent-browser` for autonomous web tasks except when project tooling conflicts; co-browsing ("open this so we can work together") means the user's real Chrome via claude-in-chrome, never an automation window—if the extension won't connect, `osascript 'open location'` gets the page in front of them while it's sorted. (since 2026-08-19 · headed agent-browser session rejected as "a test one")
- `ripgrep` over `grep`.
