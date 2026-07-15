---
name: sequential-thinking
description: A structured protocol for working through complex problems as an explicit, numbered chain of thoughts with revision, branching, evidence-grounding, and a mandatory self-criticism gate before concluding. Use this whenever a task involves genuine uncertainty, competing explanations, or consequential tradeoffs — debugging a mystery, root-cause or post-incident analysis, architecture and design decisions, choosing between libraries, migration paths, or approaches, estimating an unknown quantity, planning multi-step work, evaluating a claim or proposal, or reviewing something where being wrong is costly. Also trigger when the user says "think through", "think step by step", "reason carefully", "analyze this properly", "what's really going on", or when your first instinct is to jump straight to an answer on a problem that has already surprised you once in this session. Skip it for simple lookups, one-line fixes, and tasks with one obvious correct answer.
---

# Sequential / Critical Thinking

## Why this exists

The default failure mode on hard problems is answering in one forward pass: latch onto the first plausible explanation, gather evidence that confirms it, and present it confidently. This protocol counters that by making reasoning **external, numbered, and attackable**. Each thought is a unit of work that later thoughts can cite, test, revise, or overturn.

One research finding shapes everything here: a fluent chain is not evidence of a sound conclusion. Models can produce convincing step-by-step justifications for answers actually driven by unstated influences, and re-reading one's own reasoning without new information does not reliably fix it — it sometimes talks the reasoner out of correct answers (see `references/evidence.md`). So this protocol grades conclusions by their **external anchors** — kill conditions actually tested, observations actually made — never by how persuasive the prose reads.

A second finding explains why this is a _procedure_ and not advice: in the human debiasing literature, instructing judges to "be as fair and unbiased as possible" barely helps, while a specific operation — generate the reasons the opposite could be true — measurably corrects bias. Exhortation fails; procedure works. Every rule below is the procedural form of some way reasoning goes wrong. The chain exists to hold those anchors, not to perform rigor.

Three principles follow:

1. **Sequential**: thoughts build on each other, estimates of how many you need can change, and you may revise or branch at any point.
2. **Critical**: no conclusion ships until it has survived a deliberate attempt to break it — and the terms of that attempt are set _before_ the evidence comes in.
3. **Proportional**: thinking costs context, time, and the user's patience, and past a point more of it makes answers _worse_, not better. Depth tracks stakes and reversibility, not intellectual interest.

## Calibrating depth

Depth is a function of **stakes × reversibility**. A two-way door — a choice that is cheap to undo — rarely deserves Deep treatment no matter how interesting it is. A one-way door — a migration, a public API, a destructive operation, a recommendation someone will act on — deserves the full gate even if it looks easy.

| Depth    | Thoughts | Use when                                                                   |
| -------- | -------- | -------------------------------------------------------------------------- |
| Light    | 3–5      | Reversible, small blast radius, or a short suspect list                    |
| Standard | 6–10     | Costly to redo; several constraints or live hypotheses                     |
| Deep     | 10–20+   | Irreversible or expensive; ambiguous evidence; needs branches or subagents |

At Light depth the protocol compresses to: frame in one thought, two rivals with kill conditions, one discriminating check, verdict. Even the fast path writes kill conditions — that habit is the skill.

Estimate the count when you frame the problem and say so. The estimate is a scaffold, not a quota — grow it openly when the problem is deeper than it looked, shrink it when the answer arrives early. Never pad: measured returns on longer reasoning diminish and then go negative, with extended rumination associated with abandoning previously correct answers. Gate depth by task class, not only difficulty: on inputs carrying a plausible-but-wrong frame, planted misleading detail, or a bare truthfulness question, longer reasoning measurably hurts — monotonic degradation via distraction, spurious-correlation amplification, framing overfitting, and confabulation (2026-07-14 · `references/evidence.md` #31) — so the move there is a short chain plus a rung-3 check, not more thoughts. If a task turns out to be trivial mid-protocol, say so and answer directly.

## Thought format

Write load-bearing thoughts where they persist — the visible response or the scratchpad, not only internal reasoning (see "Running this inside Claude Code"). Each thought gets a header:

```
Thought 3/8 [hypothesis]: The 502s correlate with deploys, so the leading
suspect is connection draining being skipped during rollout.
Kill condition: 502s occurring in windows with no deploy activity.

Thought 5/8 [revise → #3]: Dead by its own kill condition — timestamps
show 502s *between* deploys too. #3's correlation was an artifact of
when I sampled logs.

Thought 6a/9 [branch ← #4: "upstream timeout"]: Suppose instead the
upstream health check timeout is shorter than the app's cold start...
```

Conventions:

- **One job per thought.** A thought that frames, hypothesizes, and concludes at once can't be revised in parts.
- **Label each thought**: `frame`, `decompose`, `hypothesis`, `evidence`, `test`, `challenge`, `revise → #N`, `branch ← #N: "name"`, `merge`, `prune`, `synthesize`, `verdict`, `postmortem`.
- **Revisions name their target and say why it was wrong.** Silently changing course hides exactly the information the trail exists to preserve.
- **Branches get a short name** and must end in `merge` or `prune` with the reason stated. No orphaned branches.
- **Reused claims carry their rung**: when a thought cites `#N`, it imports #N's verification status along with its content — "per #3 (rung 3)" and "per #3 (rung 1)" are different licenses (see "Premise inheritance").
- **Update the denominator openly**: `Thought 7/8` becoming `Thought 7/12` is the protocol working, not sloppiness.

## Know what kind of problem this is

The protocol is one spine, but different problem types weight the phases differently. Name the dominant type in your frame thought — most real tasks blend two.

| Type                                 | "Explore" produces                                 | Gate emphasizes                                         | Sharpest tools                                                                                   |
| ------------------------------------ | -------------------------------------------------- | ------------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| Diagnosis — _what broke?_            | A differential: every cause that fits the symptoms | Discriminating evidence; negative space                 | Fault tree, five whys, hypothesis×evidence bookkeeping                                           |
| Decision — _which option?_           | Option set wider than incumbent-vs-challenger      | Premortem; weight sensitivity; reversibility            | Decision matrix, premortem, inversion                                                            |
| Design — _build under constraints_   | Candidate shapes, including the boring one         | Constraint check; failure modes; "what breaks this?"    | Inversion, premortem, MECE; structure/naming/schema choices: the information-architecture corpus |
| Estimation — _what's the number?_    | Decompositions and reference classes               | Order-of-magnitude sanity; sensitivity to weakest input | Fermi bounds, base rates                                                                         |
| Verification — _is this claim true?_ | Claim → evidence → warrant map                     | Attack the warrant; source independence                 | Toulmin, base rates                                                                              |
| Planning — _what sequence?_          | Orderings with dependencies exposed                | Critical-path risk; cheapest probe first                | Premortem, fault tree, work backward                                                             |

## The verification ladder

Everything in the Ground and Challenge phases runs on one hierarchy — and it is the house's shared verification vocabulary: sibling skills (gigaresearch, gigareview, execute-plan) cite rungs by number rather than redefining them. When you need to check a claim, climb as high as the claim's importance demands:

- **Rung 3 — External.** New information from outside the chain: run the command, execute the test, measure, read the actual file, ask the user. Nothing below this rung can overturn it.
- **Rung 2 — Factored.** New computation performed _blind to the draft_: re-derive a key result by a genuinely different method and check agreement (independent convergence is one of the strongest correctness signals available), or pose verification questions and answer them from raw evidence without the draft in view. Phrase verification questions **open-form** — "what indexes exist on `returns`?" — never as leading yes/no, which invites agreeing with whatever your draft already says.
- **Rung 1 — Introspective.** Re-reading, steelmanning, bias-sweeping your own chain. Necessary hygiene, never sufficient: without new information or new computation, self-review adds noise as often as signal.

**The gate rule**: before a Standard or Deep verdict, every load-bearing claim needs rung 2 or 3. Rung-1-only clearance is acceptable only at Light depth on reversible calls. And confidence caps at the highest rung actually used — a claim checked only by re-reading cannot anchor a "high confidence" verdict, no matter how solid it feels.

## Premise inheritance: status travels with the claim

The ladder assigns a claim its rung; this section is the conservation law: **a claim's epistemic status — its rung, its hedges, its unverified assumptions — travels with it across every boundary, or the boundary launders it.** The laundering is measured, not theoretical: models over-commit to early mistakes and keep building on claims they can recognize as wrong when shown them in isolation — the transcript itself contaminates. Every handoff below is a place a guess becomes a "given":

- **Thought → thought.** Citing `#N` imports #N's rung, not just its words: "per #3 (rung 1, inferred)" and "per #3 (rung 3, observed)" license different weight. A conclusion resting only on inherited rung-1 claims is itself rung 1, however many steps it took getting there — chains launder by length.
- **Chain → ledger → resumed session.** Hedges are the first casualty of compression. BELIEFS promote to FACTS only through a new rung-3 `evidence` thought — never by surviving a summary, a compaction, or a session boundary. A resumed session treats inherited BELIEFS as open questions wearing yesterday's confidence.
- **Subagent → main chain.** A mini-verdict arrives as a _claim carrying its own assumptions_, not as evidence. Merge its assumption list into your ledger along with its conclusion; an unverified load-bearing assumption inside a subagent's verdict is now your unverified load-bearing assumption.
- **Turn → turn.** Your own earlier outputs are the most seductive premises: models measurably favor their own generations even when humans rate them no better, and users quote your tentative suggestion back as "what we established." Re-cite your past self at the rung it earned _then_, not the confidence it acquired by sitting in the transcript.
- **Source → source.** Two sources sharing one origin are one source. Citation networks demonstrably manufacture authority through bias, amplification, and the conversion of hypothesis into fact by citation alone — so before counting confirmations, check whether they are independent or an echo.
- **Task artifacts.** Tickets, TODOs, issue titles, and code comments ship premises ("fix the race condition in X" presumes there is one). The Frame-phase premise audit applies to inherited artifacts exactly as it does to the user's question.

The pre-verdict test is a provenance walk: trace each load-bearing claim backward — does the trail end at an observation, or at an inherited assertion nobody checked? An inheritance chain is only as strong as its weakest handoff.

## The protocol

### 1. Frame — always first, never skipped

State what is actually being solved, the success criteria, the constraints, and what is already known versus assumed. Restate the problem **in your own words, stripped of the user's causal vocabulary** — "why is the cache making this slow?" smuggles in a suspect; your frame should not inherit it unexamined. A wrong frame poisons every downstream thought, and most bad analyses fail here, not in the reasoning.

**Run a premise audit.** Models handle flawed premises badly by default: benchmarks find they rarely critique a question's presuppositions unless explicitly told to, and reasoning strength doesn't fix this — some models notice the flaw internally and still answer as if it were true, and a false premise inflates the whole chain that follows. The procedure that works: extract the load-bearing things the question takes as given (facts, causal claims, "the X that does Y" descriptions), and verify the ones the answer depends on against observation, not memory — checking a premise against your own recall is exactly the move that fails. Keep it proportionate: most premises are fine, and reflexive premise-disputing degrades performance on well-posed questions. Audit what's load-bearing; accept the rest. The same discipline applies to _ambiguity_: models recognize an ambiguous question far more often than they act on the recognition, so when an interpretation (not a fact) is load-bearing and the user could settle it in one line, make clarify-or-proceed an explicit decision rather than silently picking a reading. Enforce all of this as scaffold, never instinct: reasoning-trained models are measurably ~24% worse at abstention even in-domain, so clarify-or-abstain must be a checklist outcome the chain explicitly reaches or rejects.

Frames can rot mid-chain. If evidence keeps producing surprise, that is information about your model, not just about the world: stop swapping hypotheses and re-run Frame explicitly (`revise → #1`). The question itself may be wrong.

### 2. Decompose

Break the problem into sub-questions ordered so that each answer feeds the next — dependency order first, cheapest-to-verify as the tiebreak. Spend real effort here, because the decomposition is often most of the solve: given the correct decomposition, models solve nearly all problems that defeat them whole, and decompose-then-solve-in-sequence took a compositional benchmark from 16% to over 99% where flat chain-of-thought failed. For decomposition patterns (MECE splits, fault trees, dependency ordering), read `references/techniques.md`.

### 3. Explore — rivals, each with a kill condition

Produce hypotheses or options. **A single hypothesis is a red flag**: when only one explanation is on the table, every piece of evidence gets read as supporting it. Force at least two genuinely different candidates whenever the problem allows, and give each its own thought.

**Pre-register falsification.** Every hypothesis thought ends with its kill condition — the specific observation that would rule it out — written _before_ you gather evidence. Deciding what counts as disconfirming after seeing the data invites moving the goalposts; deciding beforehand makes the evidence phase honest. A hypothesis with no conceivable kill condition is not a hypothesis, it is a narrative — demote it or sharpen it.

**For search-shaped problems** — many partial paths, most of them dead ends (planning, puzzle-like configuration, constraint satisfaction) — switch from linear deepening to explicit search: propose a few candidate next steps, spend a thought evaluating each state's promise, expand the most promising, and backtrack the moment a state is provably a dead end. Deliberate search with lookahead and backtracking dramatically outperforms pushing one chain deeper on this problem shape.

**Two thrash guards**, both matching measured failure modes of long reasoning. In analyzed traces, _incorrect_ answers burned 225% more tokens with 418% more switching between thoughts, and most incorrect traces contained a correct thought that was abandoned without cause. So: develop before you switch — every hypothesis earns at least one checkable claim or a tested kill condition before you move on, and any switch is announced with one line stating what the current thought established or which observation killed it. Treat the word "alternatively" as a checkpoint, not a segue. And once a kill condition has been tested and passed, don't relitigate it without _new_ evidence — extended second-guessing is how correct answers get talked away.

### 4. Ground — evidence beats cleverness

You have tools, so use them inside the chain. When a thought makes a checkable claim — a file says X, the test fails this way, the config contains Y — check it _before_ writing the next thought, and record the result as an `evidence` thought (rung 3). This mid-task pause is not bureaucracy: giving an agent an explicit slot to process tool results _with guidance on what to think about_ produced a 54% relative improvement on a tool-heavy agent benchmark, while the same slot without guidance barely moved the needle — the labels and questions in this protocol are that guidance. Five speculative thoughts stacked on an unverified premise are worth less than one verified one.

Three disciplines keep this phase sharp:

- **Evidence must discriminate.** Evaluate each observation against _all_ live hypotheses, not just the favorite. An observation consistent with everything moves nothing. Prefer probes that split the field. When three or more hypotheses stay live, hypothesis×evidence bookkeeping helps (see `references/techniques.md` #3) — the _principles_ (weight diagnostic evidence, crown the least-inconsistent hypothesis) are sound; treat the grid itself as a lens, not a verdict.
- **Respect the evidence hierarchy.** Direct observation and reproduction beat logs; logs and code-as-written beat docs and comments; docs beat your memory of how these things usually work; memory beats bare plausibility. State which rung each key fact sits on — _I observed_ and _I infer_ are different claims.
- **Stop on value of information.** Before another test, fetch, or search, ask what you would do differently in either outcome. If the answer is nothing, skip it — thoroughness that cannot change the conclusion is procrastination with receipts.

The user is an evidence source too. When the discriminating fact is something they can answer in one line — "did anything deploy Tuesday?", "must this stay compatible with v1 clients?" — one targeted question beats a verdict built on a guess. Batch such questions rather than dribbling them out one per turn. And do this deliberately, because instinct runs the wrong way: having _more_ retrieved context makes models less likely to ask when they should — exactly the condition a tool-rich agent is always in. A full evidence pile on the wrong interpretation is still wrong.

### 5. Challenge — the critical-thinking gate

Mandatory before any verdict, and built on the ladder: the gate is not "re-read the chain and feel doubt" — it is a set of checks, each executed at the highest rung the stakes demand.

- **Assumption audit**: list the load-bearing assumptions — including _inherited_ ones: premises imported from earlier thoughts, prior turns, subagent verdicts, sources, or task artifacts (see "Premise inheritance"). Mark each verified or unverified, _and at which rung_. Any unverified load-bearing assumption either gets verified now or appears as an explicit caveat in the verdict.
- **Disconfirmation, including negative space**: check the pre-registered kill conditions honestly — did you look where disconfirming evidence would live, or merely fail to trip over it? Then check what _should_ be present if the leading answer were true but isn't. The dog that didn't bark counts against.
- **Factored verification** (rung 2): extract the 3–5 atomic facts the verdict depends on, phrase each as an open question, and answer them from the evidence alone — not from the draft. Facts survive this that mere re-reading would have rubber-stamped.
- **Build the rival, don't perform it**: role-played devil's advocacy measurably _bolsters_ the favored view rather than opening it — performed doubt is worse than useless. The steelman is therefore constructive: give the strongest alternative its own `hypothesis` thought, its own kill condition, and at least one real evidence probe, exactly as if you held it. If you can't make it a live competitor, you don't understand it well enough to reject it.
- **Bias sweep, on paper**: a chain can read as principled while the real driver is an anchor. Name the pulls explicitly — the first hypothesis, the user's framing, **wishfulness** (favoring what the user seems to want, or what lets you finish — a measured tendency of assistant models, not a hypothetical), and **chain sunk cost** (a long chain resists overturning; length is not evidence). But be honest about what naming buys: in measured tests, instructing a model to ignore an anchor barely helped — what worked was gathering evidence from multiple independent angles. Naming a pull _routes_ the fix; the fix itself is structural. So the sweep ends by pointing at structure: which rival needs development, which probe covers the angle the anchor is hiding.

For irreversible or high-stakes verdicts, add an **unanchored second opinion** — the closest available analog to an authentic dissenter: hand a fresh-context subagent the evidence only — no chain, no favorite — and compare conclusions (see "Running this inside Claude Code"). Collect independent verdicts and compare; do not stage argument rounds between agents — convergence of independent paths is the well-evidenced mechanism, while conversational debate fails two independent 2025–26 evidence lines: conformity and error propagation in debate meta-evaluations, and teams averaging below their best member via integrative compromise. Divergence is a gate failure; find out why before proceeding.

If the gate breaks your leading answer, that is the skill succeeding, not failing. Mark the revision and keep going.

### 6. Conclude

Stop when the answer survives the gate, or when new thoughts stop changing the conclusion — never merely because the estimate ran out. Close with:

```
Verdict: <the answer, stated plainly>
Confidence: high | medium | low — <one line on why>; for consequential
calls add rough odds ("~80%") — "likely" spans 55–90% in readers' heads
Would change my mind: <the specific evidence that would>
Open questions: <what remains unverified, if anything>
```

Calibrate against a known bias: verbalized confidence runs **systematically overconfident**, and worst exactly where familiarity is thinnest — strong models' nominal 99% ranges contain the truth only about two-thirds of the time. So widen ranges past what feels comfortable, and let the ladder set the tier, not fluency: _high_ requires rung 2–3 on every load-bearing claim; an unverified assumption anywhere load-bearing caps you at _medium_ and gets named. A single self-reported percentage never gates anything alone — lone verbalized confidence is severely miscalibrated (ECE up to 0.335); for consequential verdicts, derive the number from agreement across the gate's independent derivations, which is the measured repair. State odds only after the rivals are on the table: explicitly considering alternatives before verbalizing confidence is one of the few interventions shown to improve the number itself. When your confidence in the mechanism and in the recommendation differ — the diagnosis is certain but the fix is a bet — say both.

**When the gate won't pass** because the discriminating evidence is genuinely unavailable, do not manufacture confidence. Three honest moves remain: recommend the option that is **robust across the live hypotheses** (safe whichever turns out true); make the recommendation itself the **cheapest discriminating probe** ("run X for a day; it settles H1 vs H2 and is safe under both"); or **defer explicitly** — name the person, dataset, or measurement that could settle it and route the question there. Calibrated low confidence exists precisely to enable that handoff. The verdict states which move you made and why.

The verdict block closes the _chain_; the reply to the user should be shaped naturally around its content. Pasting a rigid template into a casual conversation is protocol theater — but the answer, the confidence level, and what would change it must all survive into the reply in some form.

### When the verdict is challenged

Assistant models flip settled answers under a bare "Are you sure?" nearly half the time, dropping accuracy substantially — pressure alone, carrying zero information, moves them. The rule that prevents both failure modes: **a verdict moves on evidence, not on pressure.**

When someone pushes back, first ask what's new. If the challenge carries new information or points at a specific flaw in the chain, that's ordinary business — run it through Ground and revise with a `revise → #N` if it lands. If the challenge is bare skepticism, do not re-read the chain and report renewed conviction (rung 1, worthless) and do not capitulate: run **one factored check** — re-derive the most load-bearing claim by a different route, or answer one open verification question from the evidence — then hold or revise based on what _that_ returns, and say so. "I re-checked X independently and it held" and "you were right — the re-check broke assumption #2" are both wins; flipping because someone frowned and freezing because you already committed are the same failure wearing different clothes.

## Running this inside Claude Code

The chain has to coexist with machinery Claude Code already gives you. The division of labor:

- **Internal reasoning vs. the chain**: extended-thinking blocks are ephemeral and unauditable — fine for micro-steps (arithmetic, skimming a file), wrong for load-bearing reasoning. Anything a later thought will cite, revise, or that the user should be able to audit belongs in the visible chain or the scratchpad. If a conclusion appears in the reply, its supporting chain must exist somewhere the user can inspect.
- **Plan mode**: phases 1–3 (frame, decompose, explore) are exactly what a good plan is made of. Run them _before_ presenting a plan, so the plan inherits the rivals you considered and the reasons they lost — a plan that shows only the winning option invites the user to relitigate alternatives you already pruned, without the evidence.
- **Todo lists**: todos track _execution_ state; thoughts track _epistemic_ state. A pruned hypothesis is not a completed todo, and mirroring the chain into the todo list clutters both. Keep them separate: the chain decides what to do, the todos track doing it.
- **Subagents for parallel branches**: when branches are genuinely independent and each needs real investigation, spawn an agent per branch with just that branch's question; each returns evidence plus a mini-verdict, and the main chain merges or prunes. Pin each spawn to a cheaper model (`model: 'opus'` — the CLAUDE.md model split: investigation is legwork, judging the merge is yours), and prefer schema-forced returns (`{assumptions, evidence, verdict}`) so the assumption merge is mechanical rather than prose-mining. Independence is not only speed — a subagent that never saw your favorite hypothesis evaluates evidence unanchored. And read what comes back through the inheritance lens: a mini-verdict is a claim carrying its own assumptions — merge its assumption list, not just its conclusion.
- **Research-grade evidence**: when a load-bearing claim needs multi-source web research rather than a one-command check, invoke the `gigaresearch` skill instead of ad-hoc searching. Its ledger statuses arrive pre-graded: `established` (2+ independent sources) enters your ledger as an externally-anchored FACT; `reported` enters as an attributed BELIEF, not a FACT; `contested` arrives as a live fork — hold both sides as rival hypotheses with the scope note, never flattened into one BELIEF; `unverified` stays out of the ledger entirely.
- **Subagents as red team**: for the second-opinion move in the gate, the prompt discipline matters — give the subagent the observations and the question, _not_ your conclusion or your chain, and ask open questions rather than "is my answer right?". Pin a different, cheaper model (`model: 'opus'`) by default: the pin the model split already requires is also a genuinely different reasoner, and that diversity is worth more to the gate than a same-model echo. If it converges independently, that is real corroboration. If you can't resist hinting, the exercise is theater.

## Long tasks: the ledger and the scratchpad

In long agentic sessions where context may be compacted, the chain itself is state worth keeping. Append thoughts to a scratch file (`thinking-<task>.md` in the session scratchpad directory, or `.thinking/<task>.md` in the repo if the user wants the audit trail — gitignore it otherwise) and re-read it when resuming.

For Deep-tier problems, keep a compact **epistemic ledger** at the top of the scratchpad and update it as evidence lands:

```
FACTS (observed):         502s occur between deploys; returns has no index
BELIEFS (inferred):       seq scan is the mechanism (~85%)
ASSUMPTIONS (unverified): prod schema matches staging  ← load-bearing
LESSONS (from dead ends): sampling logs only at deploy times created a
                          false correlation — sample uniformly
OPEN:                     does the join need a date filter long-term?
```

The chain is the history; the ledger is the current state, and the ledger is also where premise inheritance is enforced: BELIEFS promote to FACTS only via a new rung-3 `evidence` thought, never by surviving a summary or a session boundary — compaction eats hedges first. Update BELIEFS in small increments as each piece of evidence lands rather than in end-of-chain jumps — in forecasting tournaments, how often people updated was among the strongest behavioral predictors of accuracy. A resuming session — or a second-opinion subagent — reads the ledger first. The LESSONS line matters most across attempts: a dead end whose lesson is written down is paid for once; one whose lesson is lost gets paid for again.

## After resolution

When ground truth eventually arrives — the fix worked or didn't, the decision aged well or badly — spend one `postmortem` thought: what did the chain believe at thought N that turned out wrong, and what signal was already visible then? Calibration only improves with feedback, and the feedback compounds: in a four-year forecasting tournament, a single hour of debiasing training measurably improved accuracy for a full year afterward. The trail you kept makes your own feedback loop nearly free. A lesson that generalizes beyond this task must leave the scratchpad: stage it into the memory pipeline (CLAUDE.md §Memory) at the moment of the postmortem — scratchpads die with the session; only the staged lesson compounds.

## Anti-patterns

- **Padding** thoughts to reach the estimate. Density over count — and past the point of new information, more thinking measurably hurts.
- **Ritual challenge**: a `challenge` thought that gestures at doubt without naming a specific way the answer could be wrong. Performed dissent doesn't just fail — it measurably entrenches the favorite. If the gate never draws blood across many uses, it isn't being run honestly.
- **Rung-1 laundering**: presenting introspective re-reading as if it were verification. "I double-checked my reasoning" is not a check.
- **Confirmation shopping**: gathering only evidence that can support, never kill. Pre-registered kill conditions exist to block exactly this.
- **Leading the witness**: yes/no verification questions ("the index is missing, right?") that invite agreement with the draft. Ask open questions.
- **Speculation stacking**: building thought 6 on thought 3's guess when one command would have settled it.
- **Hidden revisions**: quietly switching answers instead of writing `revise → #N`.
- **Branch hoarding**: leaving alternatives open so no conclusion is ever wrong.
- **Thrashing**: abandoning a live hypothesis without naming its killer, or relitigating a settled one without new evidence.
- **Pressure response**: flipping a verdict because someone pushed back without new information — models do this nearly half the time under a bare "are you sure?" — or refusing to revisit when they bring real evidence. Same failure, opposite costumes: confidence tracking something other than evidence.
- **Confidence theater**: a "high" label or a precise-sounding number that the weakest link doesn't back.
- **Protocol theater**: running all six phases on a question that needed one sentence.

## Compact worked example

> _Task: "Our nightly ETL job started taking 4 hours instead of 40 minutes. Figure out why."_

```
Thought 1/7 [frame]: Diagnosis-type. Success = identify the responsible
change. Known: started ~last week. Assumed (unverified): input volume
is stable. Restated without inherited suspects: "the job got 6x slower;
find the mechanism."

Thought 2/7 [decompose]: Differential: (a) data volume/shape changed,
(b) code or query changed, (c) infrastructure changed. Order by cost
to verify: (a) row counts, (b) git log, (c) change log.

Thought 3/7 [evidence]: Row counts flat, ±2% week over week. (a) pruned
— and the frame's assumption is now verified at rung 3, not assumed.

Thought 4/7 [evidence]: git log: one merge 8 days ago — "switch orders
join to include returns table."

Thought 5/7 [hypothesis]: New join lacks an index on returns.order_id,
forcing a scan per batch.
Kill condition: EXPLAIN shows an index scan on returns.

Thought 6/7 [challenge]: Ran the kill test — EXPLAIN shows seq scan,
40M rows, no index (rung 3). Hypothesis survives its own kill
condition. Negative space: if (c) infra were the cause, the change log
would show a deploy or instance event in the window — it shows none.
Pruned on absence of expected evidence, which I looked for, not just
failed to see.

Thought 7/7 [verdict]:
Verdict: the returns-table join added 8 days ago triggers a sequential
scan; add an index on returns.order_id.
Confidence: high (~90%) — mechanism confirmed at rung 3, rivals pruned
on direct evidence.
Would change my mind: prod having the index when staging doesn't.
Open questions: whether the join also needs a date filter as returns
grows.
```

Note what made this work: the differential was enumerated before evidence arrived, the hypothesis carried its kill condition from birth, the challenge ran that test rather than performing doubt, and the infra rival was pruned by _looking for_ its expected traces and finding none.

The same spine handles decisions, compressed to show the shape:

> _Task: "Should we move our job queue from Redis to Postgres SKIP LOCKED?"_

```
Thought 1/6 [frame]: Decision-type, one-way-door-ish (migration is
costly to reverse) → Standard depth despite small system. Criteria:
ops simplicity (2-person team), throughput headroom, job durability.
Thought 2/6 [hypothesis]: A: stay on Redis. B: Postgres SKIP LOCKED
(kill: benchmarks under 2x measured peak). C: managed queue — added
so B isn't judged only against the incumbent.
Thought 3/6 [evidence]: Metrics show 11 jobs/s peak, not the 50 the
user cited (a growth guess — confirmed by asking, rung 3). SKIP
LOCKED benchmarks >1k jobs/s on this instance class. B's kill
condition not met.
Thought 4/6 [challenge]: Premortem on B: queue-table bloat under
churn; long transactions starving workers — documented, mitigable.
Premortem on A: persistence misconfig loses jobs; incident log shows
it already happened once.
Thought 5/6 [challenge]: Steelman C: least ops of all. Pruned on a
constraint, not a vibe: team explicitly avoids new cloud
dependencies (asked).
Thought 6/6 [verdict]:
Verdict: migrate to Postgres SKIP LOCKED.
Confidence: medium-high (~75%) — throughput verified; bloat
mitigation unverified on this workload. Mechanism certain, fix
partly a bet — saying both.
Would change my mind: projections showing sustained >500 jobs/s, or
heavy large-payload churn.
Open questions: autovacuum tuning for the queue table.
```

## When stuck

If a phase stalls — can't generate a second hypothesis, can't decompose, evidence is ambiguous, the gate won't pass — read `references/techniques.md` for the applicable tool (five whys, fault trees, hypothesis×evidence grids, negative-space checks, inversion, premortem, Fermi bounds, base rates, decision matrices, robust choice under uncertainty, Toulmin analysis, changing representation) and apply it as one or more labeled thoughts.

## Evidence base

The design choices above are not aesthetic. `references/evidence.md` lists the research each one rests on — what was found, where, and which rule it produced — including the places where the evidence is mixed and this skill hedges accordingly. Read it when you want to know _why_ a rule exists, or when deciding whether a situation justifies bending one.
