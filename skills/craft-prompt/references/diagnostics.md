> Referenced from SKILL.md — the failure-first index. `techniques.md` is keyed by technique; this file is keyed by SYMPTOM: what you observe in a transcript → the likely root cause in the prompt → the fix. Load it for the Debug branch, and during Refine/Review when the user reports misbehavior rather than asking for polish.

Diagnose from evidence, not vibes: get the transcript, or the exact misbehavior quoted, before prescribing — the same symptom has multiple causes, and the entries below list only the most common first. Fix with the smallest diff that removes the cause. Then keep the failing input as a regression case and re-run it after the edit.

## Rule-following

- **Obeys a rule early, drops it as the session grows.** Stated once mid-prompt; attention favors the ends → bracket it in the opener AND the trailer, or use full/sparse reminder throttling for persistent modes (→ techniques §Persistence and throttling).
- **Follows the letter, misses the point on unlisted cases.** The rule carries no rationale to generalize from → rule-first, rationale-second; the why is what transfers (→ SKILL.md principle 1).
- **One load-bearing rule lost among many.** Emphasis inflation — everything marked IMPORTANT → strip markers elsewhere; capitalize only the pivot word (→ techniques §Voice; playbook §Emphasis vocabulary).
- **Rationalizes exceptions ("surely not for THIS one").** The trivial tempting cases aren't named → enumerate them: _"Even for 'hi'. Even for 'thanks'."_ (→ techniques §Voice).
- **Ban honored, but the behavior resurfaces via another channel.** Prohibition without channel coverage → forbid across every output channel, and close the world to remove the motive (→ techniques §Leak Boundaries; §Precondition, Ordering & Cardinality Gates).

## Triggering & routing

- **Tool or skill under-fires.** Description lacks the user's literal phrasings; default tool reticence → verbatim trigger phrases in when-to-use; "use proactively"; quantify the vague threshold (→ techniques §Triggers & Use Boundaries).
- **Over-fires on near-misses.** No negative boundary → add When-NOT-to-use with the nearest mis-trigger carved out and the redirect named in the same breath (→ SKILL.md principle 4).
- **Flip-flops on ambiguous input.** Overlapping conditions with no precedence → first-match-wins ordering, most-specific first, plus a when-in-doubt tie-break (→ techniques §Routing Tables & Priority-Ordered Lookups).
- **Mentions the capability instead of invoking it.** Say–do gap → ban naming without calling; make the call a BLOCKING REQUIREMENT before any prose; ensure examples show the invocation, not an inline answer (→ techniques §Interaction; §Meta-Prompt Example Generation).

## Fabrication & false success

- **Claims done without checking.** No evidence contract → evidence-required output: _"a check without a Command run block is not a PASS — it's a skip"_ (→ claude-code/exemplars.md: verification agent).
- **Predicts or fabricates a pending result.** Async discipline missing → _"never fabricate in any format — not as prose, summary, or structured output"_; trust the notification (→ techniques §Persistence; §Leak Boundaries).
- **Hedges results that actually passed.** One-sided honesty rule → report outcomes faithfully in both directions (→ claude-code/exemplars.md: core system prompt).
- **"Let me check…" from a context that cannot act.** Verbal tics unbanned → quote and ban them verbatim; prescribe the don't-know case (→ claude-code/exemplars.md: side-question fork).
- **Invents options, URLs, API params.** Open world → closed-world enumeration with an invention ban; inline the catalog it must pick from (→ techniques §Closed-World Enumeration & Invention Bans).

## Scope & effort

- **Gold-plates: refactors, configurability, unasked polish.** Temptations unnamed → anti-gold-plating cluster naming the concrete temptations; match scope to the request (→ techniques §Scope Calibration & Artifact Upkeep).
- **Stops at the polished 80%.** Value not anchored → _"your entire value is in finding the last 20%"_; rationalizations catalog with counters (→ claude-code/exemplars.md: verification agent).
- **Summarizes instead of finishing.** Stop cues misread as conclusions → completion-gate blacklist; _"keep working — do not summarize"_ (→ techniques §Persistence; playbook §Stock phrasebook).
- **Stalls: over-asks, waits, narrates idleness.** Permission not pre-granted → assume capability; bias-toward-action with a course-correct license; MUST-act/sleep rules for loops (→ techniques §Voice; §Persistence and throttling).
- **Too bold: destructive or outward actions without consent.** No risk model → reversibility × blast-radius framing; authorization is scoped and non-transitive (→ claude-code/exemplars.md: Safety).

## Output shape

- **Breaks the downstream parser.** Format left to taste → closed-world literals, first token pinned, strip `<thinking>` before matching (→ SKILL.md anatomy §E).
- **Verbose; answer buried.** "Be concise" is unenforceable → numeric length anchors; a lead-with-answer whitelist of what output is FOR (→ techniques §Output formats).
- **Meta-instructions leak into the deliverable.** Instruction channel unscrubbed → forbid the plumbing vocabulary by name; fence the instruction turn out of its own input scope (→ techniques §Leak Boundaries & Durable-Artifact Integrity).
- **Format drifts run to run.** Field list but no specimen → one fully-rendered specimen; template with literal placeholders and loop markers (→ techniques §Rendered Format Specimens & Output Templates).
- **Reproduces example content, not example shape.** Specification confused with illustration → vary surface details across examples; add `<reasoning>` naming the discriminating criteria; spend equal space on when-NOT cases (→ techniques §Teaching Wrappers & Reasoning Annotation).

## Delegation

- **Delegate returns an unusable report.** Consumer and shape unstated → name the downstream consumer, the length cap, and the return channel (→ techniques §Briefing The Delegate; §Return Channel & Output Visibility).
- **Parent redoes or peeks at delegated work.** Costs unnamed → don't-peek justified by context pollution; don't-duplicate rule (→ techniques §Spawn, Reuse & Delegation Economy).
- **Fork greets, apologizes, or re-delegates.** Inherited context misread as its own history → skim-breaking interrupt; quote-and-revoke the inherited directive; deny the false self-story outright (→ techniques §The Fork's Self-Model & Audience).

## Context & durability

- **Behavior degrades after compaction.** Prompt isn't summary-proof → make the body self-explaining post-summary; restate the two load-bearing constraints in a critical reminder (→ claude-code/architectures.md §5).
- **Forgets facts from cleared tool output.** No persistence directive → _"write down any important information … the original tool result may be cleared later"_ (→ playbook §Stock phrasebook).
- **Stale priors beat live facts (wrong year, old product names).** Live values not injected → interpolate the current date, limits, and paths; restate renames parenthetically (→ playbook §Template variables).

---

A symptom not listed here: encode it into this index directly — symptom → root cause → fix, citing the transcript artifact (Golden Rule; there is no capture queue).
