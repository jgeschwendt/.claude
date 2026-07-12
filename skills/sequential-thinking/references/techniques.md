# Critical-Thinking Toolbox

Reach for these when a protocol phase stalls. Each entry says when to use it and how to express it as thoughts in the chain. Don't run techniques for their own sake — a technique earns its place by producing a hypothesis, killing one, sharpening the frame, or forcing a decision.

## Contents

1. Five Whys — shallow cause, need the deep one
2. Fault Tree — many possible causes, need coverage
3. ACH Grid — 3+ live hypotheses, growing evidence pile
4. Negative-Space Check — leading hypothesis needs a harder test
5. Inversion — stuck on "how to succeed"
6. Premortem — decision feels settled too easily
7. Fermi Bounds — "is this even plausible?"
8. Base Rates / Outside View — seduced by the specific story
9. MECE Decomposition — messy overlapping sub-problems
10. Decision Matrix — 3+ options, 3+ criteria
11. Robust Choice Under Uncertainty — the gate won't pass
12. Toulmin Analysis — evaluating someone else's argument
13. Change the Representation — the problem won't move
14. Explain-to-a-Novice — conclusion feels right but fuzzy
15. Confidence Calibration — writing the verdict

---

## 1. Five Whys

**When**: you found *a* cause but it feels proximate — fixing it wouldn't prevent recurrence.

Ask "why did that happen?" repeatedly (usually 3–5 layers) until you hit a cause that is actionable at the process or design level. Stop when the answer becomes "because physics" or leaves your control.

As thoughts: a chain of `evidence`/`hypothesis` thoughts, each one layer deeper. Verify each layer before descending — a wrong "why" at layer 2 makes layers 3–5 fiction.

## 2. Fault Tree

**When**: root-cause analysis where you need to be sure nothing was missed, not just find one plausible culprit.

Start from the failure, split into disjoint causal categories (e.g., input / code / config / infra / timing), then split each until leaves are individually testable. Prune branches with evidence; whatever survives is the suspect list.

As thoughts: one `decompose` thought drawing the tree, then `evidence` thoughts pruning leaves. The tree's value is proving the *pruned* branches dead, so cite the observation that killed each one.

## 3. ACH Grid (Analysis of Competing Hypotheses)

**When**: three or more hypotheses stay live while evidence accumulates, and you catch yourself scoring each new fact only against the favorite.

Build a small grid: hypotheses as columns, pieces of evidence as rows, each cell marked consistent (+), inconsistent (−), or neutral (0). Two rules carry the value: judge the winner by **least inconsistency**, not most consistency (a hypothesis compatible with everything has explained nothing), and weight **diagnostic** evidence — rows that split the columns — over rows that mark every column the same.

Honesty note (see `evidence.md` #9): controlled studies of the classic ACH ritual are unflattering — the matrix did not measurably reduce confirmation bias, and its verdicts are sensitive to small changes in how evidence is rated. The *principles* above are standard Bayesian practice and belong in every Ground phase; the grid is bookkeeping that makes them visible. Treat its output as a lens on the evidence, never as a verdict, and never let filling cells substitute for running the probe that would actually discriminate.

As thoughts: one `synthesize` thought containing the grid, one identifying which *missing* row would be most diagnostic — that row is your next probe.

```
                        H1 index   H2 volume   H3 infra
502s between deploys       +           +          −
row counts flat            +           −          +
EXPLAIN: seq scan          +           0          −
```

## 4. Negative-Space Check

**When**: the leading hypothesis has survived confirmation and needs a harder test — or a rival needs honest pruning.

Enumerate the traces the hypothesis *predicts should exist* if true — log lines, metrics movement, correlated failures, a config value — then go look for each. Expected evidence that is absent counts against, but only if you searched where it would live; failing to trip over something is not the same as its absence.

As thoughts: a `challenge` thought listing predicted traces, then `evidence` thoughts reporting present/absent for each. This is also the honest way to prune a rival: "if H3 were true, the change log would show X in the window; it shows nothing" beats "H3 seems unlikely."

## 5. Inversion

**When**: "what's the best design/plan?" is producing bland answers.

Flip it: "what would guarantee this fails?" — then check the current plan against each failure mode. People are better at spotting flaws than imagining virtues; inversion exploits that.

As thoughts: a `challenge` thought listing 3–5 guaranteed-failure conditions, then one thought mapping each onto the current plan.

## 6. Premortem

**When**: a decision is nearly made and everyone (including you) has stopped questioning it.

Assume it's 12 months later and the decision *has already failed* — write the story of *why*: specific, causal, plausible. The certainty framing is the active ingredient, not decoration: imagining an outcome as an accomplished fact produces roughly 30% more reasons and about twice as many concrete, action-based ones than asking "what could go wrong?", and cuts overconfidence about twice as much as pros/cons-style review (Mitchell, Russo & Pennington 1989; Veinott et al. 2010 — see `evidence.md` #8). "Any concerns?" invites vague unease; "it failed — explain it" produces mechanisms.

As thoughts: one `challenge` thought per distinct failure story. Any story that survives scrutiny becomes a caveat or a mitigation in the verdict.

## 7. Fermi Bounds

**When**: a claim or estimate needs a sanity check before you invest thoughts in it ("will this fit in memory?", "can this queue handle the load?").

Decompose into factors you can estimate within 10x, multiply, and compare orders of magnitude. You're not after precision — you're after "plausible" vs "impossible."

As thoughts: one `evidence` thought showing the arithmetic, ending with which input the result is most sensitive to. If the bound lands within 10x of the threshold that matters, escalate to real measurement instead of trusting the estimate. For any standalone estimate, a cheap accuracy boost: make a second estimate under consider-the-opposite instructions ("assume the first was off — which direction, and why?") and average the two — "dialectical bootstrapping" (Herzog & Hertwig, Psychological Science 2009).

## 8. Base Rates / Outside View

**When**: the specific story in front of you is compelling — which is exactly when reference-class evidence gets ignored.

Ask: across all cases like this one, what usually turns out to be true? "It's probably not a compiler bug" is a base rate. "Most performance regressions are the most recent change" is a base rate. Start from the reference class, then let case-specific evidence move you off it.

As thoughts: a `hypothesis` thought stating the base-rate prior, then `evidence` thoughts updating it. Deviating far from the base rate demands proportionally strong evidence — say so explicitly if you do. For plans and estimates this is not optional garnish: across 258 infrastructure projects in 20 nations, roughly 90% ran over cost with no accuracy improvement across 70 years of data, and the draft plan itself becomes the anchor for every later estimate — which is why starting from the reference class ("what did similar efforts actually take?") is mandated for major UK and Danish public projects, and why Kahneman called the outside view the single most important advice for forecasting accuracy. Treat the reference class as the prior, not the verdict; some project classes show the opposite bias.

## 9. MECE Decomposition

**When**: sub-problems overlap or the split feels leaky, so effort double-counts or gaps hide.

Force the split to be Mutually Exclusive (no case in two buckets) and Collectively Exhaustive (every case in some bucket). Test with adversarial examples: invent a case and check it lands in exactly one bucket.

As thoughts: a `decompose` thought stating the buckets plus one line proving exhaustiveness ("any request is either read or write; reads split into cached/uncached...").

## 10. Decision Matrix

**When**: three or more options against three or more criteria — beyond what prose comparison handles honestly.

List criteria, weight them (state why), score each option per criterion, and — crucially — check whether the winner is robust to reasonable changes in the weights. A winner that flips when one weight moves 20% is a coin flip wearing a spreadsheet.

As thoughts: one `synthesize` thought with the table, one `challenge` thought on weight sensitivity.

## 11. Robust Choice Under Uncertainty

**When**: the challenge gate won't pass because the discriminating evidence is genuinely unavailable, but a recommendation is still owed.

Three moves, in order of preference:

- **Dominance**: eliminate any option that is worse than another under *every* live hypothesis. Sometimes only one survives.
- **Least regret**: for each option, ask "how bad is this if the *other* hypothesis is true?" Pick the option whose worst case is most tolerable — especially when one branch is irreversible.
- **Cheap probe as the recommendation**: design the smallest safe action that discriminates between the live hypotheses, and recommend *that* ("feature-flag it for one region for a day"). Acting to learn beats guessing confidently.

As thoughts: a `synthesize` thought mapping options × hypotheses, then a `verdict` that names which of the three moves it used. Never dress this situation up as high confidence — the honesty *is* the value.

## 12. Toulmin Analysis

**When**: evaluating an argument someone else made — a design doc, a vendor claim, a postmortem.

Separate the **claim** from the **evidence** from the **warrant** (the usually-unstated rule connecting them). Most bad arguments have fine evidence and a broken warrant: "latency dropped after the change (evidence), so the change caused it (claim)" — the warrant assumes nothing else changed.

As thoughts: one thought extracting claim/evidence/warrant, one `challenge` thought attacking the weakest of the three.

## 13. Change the Representation

**When**: the problem won't move — no new hypotheses, decomposition keeps producing the same tired split, everything feels simultaneously connected.

Three classic moves, any of which can be one thought:

- **Draw it**: sketch the system as a graph (components, data flow, timing) in a fenced block. Tangles that hide in prose are visible in structure — cycles, single points of failure, the component every arrow touches.
- **Work backward**: start from the desired end state (or the observed failure) and reason toward the present. Forward search asks "what can I do?"; backward search asks "what must have been true?" — often a much smaller space.
- **Find the solved analog**: "what known problem is this an instance of?" A bespoke-looking issue is often cache invalidation, backpressure, split-brain, or clock skew wearing a costume — and the analog imports both hypotheses and known fixes.

As thoughts: a `decompose` or `hypothesis` thought per move. If the new representation changes nothing, that is also information — the difficulty is real, not representational.

## 14. Explain-to-a-Novice

**When**: the conclusion feels right but you can't state it crisply — often a sign the reasoning has a gap you're papering over with familiarity.

Write the explanation as if for a smart newcomer with zero context. Every place you reach for "obviously" or "basically" is a place to inspect.

As thoughts: a `synthesize` thought containing the novice explanation. If writing it exposes a gap, that gap becomes the next `evidence` or `revise` thought.

## 15. Confidence Calibration

**When**: writing any verdict.

Confidence tracks the *weakest load-bearing link*, not the average strength of the reasoning:

- **High (~85%+)**: every load-bearing claim verified at rung 2–3 of the ladder; rivals pruned on evidence, not preference; kill conditions actually tested.
- **Medium (~60–85%)**: mechanism is sound but at least one load-bearing assumption is unverified — name it.
- **Low (<60%)**: choosing between rivals on plausibility because the discriminating evidence is unavailable — say what that evidence would be, and consider Robust Choice (#11) instead of a bare pick.

Then correct for a measured bias: verbalized confidence runs systematically high — calibration error around ten points even for strong models, nominal 99% ranges covering the truth only about two-thirds of the time, and the gap widest exactly where familiarity is thinnest (see `evidence.md` #7). Practical rules: widen ranges past what feels comfortable; treat unfamiliar territory as the highest-overconfidence zone, not a place to hedge less; and let the ladder set the tier, not the fluency of the chain.

Rough numbers beat bare words for consequential calls: "likely" means 55% to one reader and 90% to another; "~75%" transmits. When confidence in the mechanism and in the recommendation differ, state both. The user acts on the label, not the prose.
