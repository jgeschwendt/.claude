# Evidence Base

> Citations audited against live sources 2026-07-12 (six-agent fan-out): every cited source resolves with matching title/authors; abstract-verifiable numbers match verbatim. Corrections applied then: entry 25's "deliberation time" cut, entry 16's unguided-slot figure precised, entry 27's GEAR labeled abductive. Body-only figures remain unverified-at-abstract-depth, not disputed.

What the research says, and which rule in this skill it produced. Each entry: the finding, the source, the design consequence. This file exists so the rules can be trusted, bent intelligently, or challenged — a skill about critical thinking should survive its own gate.

## 1. Intrinsic self-correction fails without new information

**Finding**: LLMs asked to review and correct their own reasoning _without external feedback_ do not reliably improve, and performance sometimes degrades after self-correction — the model talks itself out of correct answers.
**Source**: Huang et al., "Large Language Models Cannot Self-Correct Reasoning Yet," ICLR 2024 (arXiv:2310.01798).
**Design consequence**: the verification ladder. Introspective review (rung 1) is hygiene, never clearance; the gate requires new information (rung 3) or new computation (rung 2) on every load-bearing claim before a Standard/Deep verdict.

## 2. Factored verification beats holistic re-checking

**Finding**: Having a model generate verification questions about its own draft and answer them _without the draft in context_ ("factored" CoVe) reduces hallucination; verification questions are individually answered more accurately than the same facts inside a long generation. Yes/no-format verification performs worse — models tend to agree with stated facts whether right or wrong.
**Source**: Dhuliawala et al., "Chain-of-Verification Reduces Hallucination in Large Language Models," Findings of ACL 2024 (arXiv:2309.11495).
**Design consequence**: the gate's factored-verification step (atomic open-form questions answered from evidence, not the draft), the "leading the witness" anti-pattern, and the blind-subagent prompt discipline (observations and question only, never the conclusion).

## 3. Stated reasoning can rationalize, not explain

**Finding**: Chain-of-thought explanations can systematically misrepresent the true cause of a model's answer — models influenced by injected biases produced plausible step-by-step justifications that never mentioned the bias, with accuracy drops up to 36% on affected tasks.
**Source**: Turpin et al., "Language Models Don't Always Say What They Think," NeurIPS 2023 (arXiv:2305.04388).
**Design consequence**: conclusions are graded by external anchors (tested kill conditions, cited observations), never by chain fluency; the bias sweep requires naming the pulls _on paper_ (anchor, user's framing, wishfulness), since an unstated influence steers silently.

## 4. Independent convergence is a strong correctness signal

**Finding**: Sampling multiple diverse reasoning paths and taking the agreed answer ("self-consistency") substantially beats trusting one chain — e.g., +17.9% absolute on GSM8K, +11.0% SVAMP, +12.2% AQuA.
**Source**: Wang et al., "Self-Consistency Improves Chain of Thought Reasoning in Language Models," ICLR 2023 (arXiv:2203.11171).
**Design consequence**: rung 2's independent re-derivation (same result via a genuinely different method), and treating agreement between the main chain and an unanchored subagent as real corroboration — while disagreement is a gate failure that demands investigation.

## 5. Search-shaped problems need search, not longer chains

**Finding**: Deliberate exploration over a tree of partial solutions — propose candidate steps, evaluate state promise, expand the best, backtrack — dramatically outperforms linear chains on planning/search tasks: GPT-4 went from 4% (chain-of-thought) to 74% success on Game of 24.
**Source**: Yao et al., "Tree of Thoughts: Deliberate Problem Solving with Large Language Models," NeurIPS 2023 (arXiv:2305.10601).
**Design consequence**: the Explore phase's search mode and the branch/merge/prune mechanics — with the rule that branches are evaluated and closed, not hoarded.

## 6. More thinking is not monotonically better

**Finding**: Marginal returns on longer reasoning diminish and go negative; extended reasoning is associated with _abandoning previously correct answers_ (overthinking). The converse failure, underthinking, is also measured: incorrect traces often contained a correct intermediate thought early that was abandoned without cause. Models misallocate compute in both directions relative to problem difficulty.
**Sources**: "When More Thinking Hurts: Overthinking in LLM Test-Time Compute Scaling" (2026, arXiv:2604.10739); "Does Thinking More Always Help?" (2025, arXiv:2506.04210); "Reasoning on a Budget" survey (2025, arXiv:2507.02076); underthinking metric per Wang et al. 2025, in "A Survey on Test-Time Scaling" (arXiv:2503.24235).
**Design consequence**: proportional depth (stakes × reversibility), the never-pad rule, and the two thrash guards — no abandoning a hypothesis without naming its killer; no relitigating a passed kill condition without new evidence.

## 7. Verbalized confidence is systematically overconfident

**Finding**: Models' stated confidence exceeds their accuracy across sizes and tasks (expected calibration error ≈10% even for 70B+ models); nominal 99% confidence intervals on estimation tasks covered the truth only ~65% of the time; overconfidence is worst on claims the model knows least about.
**Sources**: "On Verbalized Confidence Scores for LLMs" (arXiv:2412.14737); Epstein et al., "LLMs are Overconfident: FermiEval" (arXiv:2510.26995); Wang & Stengel-Eskin, "Calibrating Verbalized Confidence with Self-Generated Distractors" (arXiv:2509.25532).
**Design consequence**: confidence is capped by the verification rung actually used, not by felt certainty; ranges get widened past comfortable; low-familiarity territory is treated as the _highest_-risk zone for overconfidence, not a place to hedge less.

## 8. Prospective hindsight ("it already failed") outperforms "what could go wrong?"

**Finding**: Framing a future event as having already occurred with certainty increases the number of reasons people generate by roughly 30%, with about twice as many concrete, action-based reasons; a controlled comparison found the premortem reduces overconfidence about twice as much as pros/cons-style evaluation.
**Sources**: Mitchell, Russo & Pennington, "Back to the Future," J. Behavioral Decision Making 1989; Klein, "Performing a Project Premortem," HBR 2007; Veinott, Klein & Wiggins 2010.
**Design consequence**: the premortem technique's phrasing rule — stipulate failure as a fact and explain it; never ask "any concerns?"

## 9. The ACH grid: sound principles, mixed evidence for the ritual

**Finding**: Empirical tests of Heuer's Analysis of Competing Hypotheses are sparse and unflattering to the ritual itself: the classic matrix did not reduce confirmation bias in controlled studies, its conclusions are sensitive to small changes in evidence ratings, and in one study a transposed layout helped while the canonical one didn't. The underlying _principles_ — enumerate alternatives, weight diagnostic evidence, judge by least inconsistency — remain standard Bayesian practice.
**Sources**: Dhami et al., Applied Cognitive Psychology 2019; Dhami et al., Cognitive Research: Principles & Implications 2024.
**Design consequence**: diagnosticity and least-inconsistency live in the core Ground phase; the grid itself is demoted to optional bookkeeping ("a lens, not a verdict"). This skill practices what it preaches: when the evidence for a technique is weak, the technique gets downgraded.

## 10. Lessons persisted across attempts improve later attempts

**Finding**: Agents that write verbal reflections on failures and carry them into subsequent attempts markedly outperform retry-without-memory across decision-making, reasoning, and coding tasks.
**Source**: Shinn et al., "Reflexion: Language Agents with Verbal Reinforcement Learning," NeurIPS 2023 (arXiv:2303.11366).
**Design consequence**: the ledger's LESSONS line and the post-resolution `postmortem` thought — a dead end whose lesson is written down is paid for once.

## Intellectual lineage (pre-LLM)

The chain's spine borrows from traditions with long track records rather than novelty: Platt's "strong inference" (Science, 1964) — multiple hypotheses with crucial, pre-committed experiments; Heuer's _Psychology of Intelligence Analysis_ (1999) — diagnosticity over confirmation; Tetlock & Gardner's _Superforecasting_ (2015) — granular probabilities, outside view first, update in increments, score yourself afterward; and Kahneman's inside/outside-view distinction. Where modern LLM findings and these traditions agree — pre-commit the test, verify blind, respect base rates, calibrate against feedback — this skill treats the agreement as the strongest available signal of a real effect.

---

# Round 2 findings (deep-research pass)

## 11. Unfaithfulness persists in RL-trained reasoning models

**Finding**: State-of-the-art reasoning models (Claude 3.7 Sonnet, DeepSeek R1) given hints they demonstrably used revealed that usage in their chain-of-thought less than 20% of the time in most settings; faithfulness is lower on harder tasks; outcome-based RL improves it initially, then plateaus; reward-hacking behavior was almost never verbalized.
**Source**: Chen et al. (Anthropic), "Reasoning Models Don't Always Say What They Think," 2025 (arXiv:2505.05410).
**Design consequence**: the externalization rationale holds for the current model class, and hardens the rule: the chain is where anchors are _held and tested_, never a confession to be trusted on its own.

## 12. Sycophancy is a measured property of assistant models

**Finding**: Five state-of-the-art assistants consistently produced responses matching user beliefs over accurate ones across four free-form tasks; analysis of preference data shows matching the user's views is among the most predictive features of human preference, and both humans and preference models sometimes prefer convincingly written sycophantic responses over correct ones.
**Source**: Sharma et al., "Towards Understanding Sycophancy in Language Models," ICLR 2024 (arXiv:2310.13548).
**Design consequence**: the bias sweep's "wishfulness" item and the Frame rule to restate problems stripped of the user's causal vocabulary are countermeasures to a documented pull, not hypothetical hygiene.

## 13. Consider-the-opposite beats exhortation

**Finding**: Inducing people to generate reasons the opposite could be true corrected biased evidence assimilation and biased hypothesis testing better than explicit instructions to "be as fair and unbiased as possible"; replicated recently with police investigators (N=100), who generated more alternative hypotheses under the instruction.
**Sources**: Lord, Lepper & Preston, JPSP 1984; Fahsing, Rachlew & May 2023.
**Design consequence**: the meta-principle of the whole skill — specific procedure over exhortation — plus direct grounding for the disconfirmation step. Bonus for estimation: averaging a first estimate with a second made under consider-the-opposite instructions improves individual judgments ("dialectical bootstrapping," Herzog & Hertwig, Psych. Science 2009).

## 14. Authentic dissent works; role-played devil's advocacy backfires

**Finding**: An authentic dissenting minority outperformed all three tested forms of devil's advocate at stimulating divergent thinking and solution quality; role-played advocacy primarily stimulated _cognitive bolstering of the initial viewpoint_. The closest effective clone of authentic dissent is a seriously produced written contra-case.
**Source**: Nemeth, Brown & Rogers, European J. Social Psychology 2001.
**Design consequence**: the steelman is constructive (the rival gets its own hypothesis, kill condition, and probe), the "ritual challenge" anti-pattern gains teeth, and the unanchored subagent — which may genuinely disagree because it never saw the favorite — is the structural approximation of an authentic dissenter.

## 15. Premature closure is the top diagnostic failure; widen the differential early

**Finding**: In diagnostic-error studies, faulty synthesis is the most common cognitive error class and premature closure the single most common cause. A pilot RCT of end-stage differential checklists did not significantly reduce overall error (11.2% vs 17.8%, p=.46) but doubled the diagnoses considered (6.5 vs 3.4, p<.001), with improvement in an emergency-department subgroup.
**Sources**: Graber et al. 2005 (as reported in Ely & Graber, Diagnosis 2015); Ely & Graber pilot RCT.
**Design consequence**: the strongest lever sits in Explore (rivals generated early, before commitment), not in end-stage checklist recitation; the gate is framed as a diagnostic time-out, and this skill deliberately ships no standalone checklist file — the evidence for that form is mixed.

## 16. A guided mid-task thinking slot measurably helps agents

**Finding**: Giving Claude a dedicated "think" slot during tool-use tasks, paired with domain-specific guidance on what to think about, yielded a 54% relative improvement on τ-bench's airline domain (pass^1 0.570 vs 0.370); the slot without guidance gained far less (0.404 vs 0.332 baseline). Most useful for tool-output analysis, policy-heavy environments, and sequential decisions.
**Source**: Anthropic engineering, "The 'think' tool," 2025.
**Design consequence**: the `evidence`-thought-after-tool-output rule, and the observation that the guidance is the active ingredient — this skill is that guidance, generalized.

## 17. How confidence is elicited changes its quality

**Finding**: For RLHF-tuned models, verbalized confidence is better calibrated than the model's internal conditional probabilities (~50% relative reduction in expected calibration error), and prompting the model to consider multiple answer options before stating confidence improves calibration further; the stated purpose of calibration is enabling deferral on low-confidence calls.
**Source**: Tian et al., "Just Ask for Calibration," EMNLP 2023 (arXiv:2305.14975).
**Design consequence**: rough odds are stated only after rivals are enumerated, and explicit deferral joins robust choice and cheap probes as the third honest move when the gate won't pass.

## 18. Premise critique doesn't happen unless you make it happen

**Finding**: Most models show limited ability to autonomously critique flawed premises and rely on explicit prompting; reasoning capability doesn't reliably predict premise-critique ability, and some models catch the flaw internally without articulating it; flawed premises also deepen overthinking. Decomposing a question into atomic assumptions and validating them against _retrieved_ evidence outperforms direct detection — model-generated evidence is detrimental — while blanket premise-suspicion prompting degrades performance on well-posed questions.
**Sources**: "Don't Take the Premise for Granted" (arXiv:2505.23715); Wang & Blanco, EMNLP 2025 (arXiv:2508.15139); Vu et al. as reported in arXiv:2504.06438.
**Design consequence**: Frame's premise audit — explicit, atomic, evidence-checked, and proportionate.

## 19. Second opinions: independent convergence is proven; staged debate is not

**Finding**: Multi-agent debate improved reasoning and factuality in its original evaluations, but a systematic re-evaluation of five debate methods across nine benchmarks and four models found the literature's evaluation practices weak — limited benchmarks, weak baselines, inconsistent setups — and argued the approach is overvalued relative to simpler baselines, with model heterogeneity the more promising ingredient.
**Sources**: Du et al., ICML 2024 (arXiv:2305.14325); "Stop Overvaluing Multi-Agent Debate" (arXiv:2502.08788).
**Design consequence**: the second opinion is collected as an independent verdict and compared (the self-consistency mechanism, entry #4), never staged as argument rounds; use a different model or configuration for the second pass when available.

---

# Round 3 findings (loop continuation)

## 20. Verdicts flip under contentless pressure

**Finding**: In the FlipFlop experiment across 9–10 models, LLMs flipped their answers 46% of the time on average when challenged with utterances like "Are you sure?", with accuracy dropping about 17% from first answer to final — the challenge carries no information, yet it moves the verdict.
**Sources**: Laban et al. 2024 (arXiv:2311.08596); quantification as reported in arXiv:2510.22866.
**Design consequence**: the "When the verdict is challenged" protocol — bare pushback triggers one factored re-check, never a re-read-and-reaffirm and never a capitulation — and the "pressure response" anti-pattern.

## 21. Underthinking is thought-thrashing, and it's measurable

**Finding**: In o1-like reasoning traces, incorrect responses consumed 225% more tokens with 418% more frequent switching between thoughts than correct ones; most incorrect responses contained at least one correct thought that was abandoned; penalizing switch tokens (e.g., "alternatively") at decode time improved accuracy on hard math without fine-tuning.
**Source**: Wang et al., "Thoughts Are All Over the Place," 2025 (arXiv:2501.18585).
**Design consequence**: the minimum-development rule — every hypothesis earns a checkable claim or a tested kill condition before switching, switches are announced with what was established or what killed the thought, and "alternatively" is treated as a checkpoint.

## 22. Anchoring is measured in LLMs — and naming it isn't enough

**Finding**: LLMs (GPT-4, Gemini, others) anchor numerical judgments on provided hints; mitigation experiments found Chain-of-Thought, explicit "ignore the anchor" instructions, and reflection insufficient, while collecting hints/evidence from comprehensive angles worked.
**Sources**: Lou & Sun (arXiv:2412.06593; J. Computational Social Science 2026); IEEE Intelligent Systems 2025 anchoring study.
**Design consequence**: honest correction to the bias sweep — naming a pull routes the fix but doesn't deliver it; the deliverable fix is structural (developed rivals plus evidence from independent angles), which is why the sweep ends by pointing at the next probe.

## 23. Models recognize ambiguity but don't act on it

**Finding**: Models often correctly judge a question as ambiguous when explicitly asked, yet overwhelmingly default to direct answers in practice; retrieved context makes them _less_ likely to ask clarifying questions; a selective classify-then-clarify pipeline (CLAM) significantly improved accuracy on ambiguous questions with only a small conversation-length cost.
**Sources**: "Knowing but Not Showing" (arXiv:2605.25284); Kuhn et al., CLAM (arXiv:2212.07769).
**Design consequence**: clarify-or-proceed is an explicit micro-decision in Frame, and Ground warns that a rich evidence pile suppresses asking exactly when interpretation risk is highest.

## 24. The decomposition is most of the solve

**Finding**: Least-to-most prompting — decompose, then solve subproblems in an order where each answer feeds the next — took the SCAN compositional benchmark from 16% (chain-of-thought) to 99.7% with 14 exemplars; the authors note nearly all GSM8K problems become solvable once the correct decomposition is supplied.
**Source**: Zhou et al., ICLR 2023 (arXiv:2205.10625).
**Design consequence**: Decompose orders sub-questions by dependency first (cheapest-to-verify as tiebreak) and is treated as a first-class phase, not a formality.

## 25. Judgment practice compounds: training, teaming, incremental updating

**Finding**: In the IARPA geopolitical tournaments, a sub-one-hour debiasing module improved Brier accuracy 6–11% over a full year; forecasters on teams beat solo forecasters; update frequency per question was among the strongest behavioral predictors of accuracy; roughly half the superforecaster advantage is noise reduction. (A "deliberation time" claim was cut 2026-07-12: the checked source reports no significant time difference between conditions.)
**Sources**: Mellers et al. / Good Judgment Project, Judgment and Decision Making (Cambridge); Satopää et al. noise decomposition.
**Design consequence**: the ledger's incremental BELIEFS updates, the postmortem's compounding-feedback rationale, and a fair framing of the protocol itself as (in part) a noise-reduction device.

## 26. Plans anchor on themselves; the outside view is the fix

**Finding**: Across 258 infrastructure projects in 20 nations, ~90% ran over cost with no accuracy improvement across 70 years of data; the preliminary plan itself acts as the anchor for all subsequent estimates; reference class forecasting is mandated for major UK (2004+) and Danish (2009+) public projects, with Kahneman calling the outside view the single most important advice for forecasting accuracy. Hedge: the literature is not unanimous — some project classes show pessimism bias, and RCF is not uniformly superior — so the reference class is the prior, not the verdict.
**Sources**: Flyvbjerg, Holm & Buhl 2002; Flyvbjerg RCF-in-practice papers; 2025 RCF review (Production Planning & Control).
**Design consequence**: the base-rates technique gains its planning-specific teeth; estimates start from the reference class before case-specific adjustment.

## 27. Corroboration round (saturation probes)

**Findings**: (a) In a year-long simulated-startup benchmark across 12 models, scratchpad use — not model capability — was the strongest predictor of long-horizon survival, and memory-architecture ablations show the scratchpad's contribution grows with context length. (b) Hypothesis-generation research converges on pool-then-filter: sample multiple candidate hypotheses, keep those consistent with observations, group by mechanism family; one-shot generation suffers premature collapse onto a single candidate.
**Sources**: YC-Bench coverage and Anthropic long-task agent reports (2026); "Benchmarking and Enhancing Long-Term Memory in LLMs" (arXiv:2510.27246); "Generating Diverse Hypotheses for Inductive Reasoning" (arXiv:2412.13422); GEAR (arXiv:2509.24096, abductive-reasoning evaluation).
**Design consequence**: none — these independently corroborate the ledger/scratchpad and the rivals-with-kill-conditions mechanics as designed. Recorded because a skill that logs only the evidence that changed it would be running its own confirmation bias in reverse.

---

# Round 4 findings (premise inheritance)

## 28. Chains launder early errors into premises

**Finding**: Language models over-commit to early mistakes, generating further false claims to stay consistent with their own transcript — while recognizing 67% (GPT-3.5) and 87% (GPT-4) of those same mistakes when shown them in isolation, in a separate session. The error survives _because_ it is in the context.
**Source**: Zhang, Press, Merrill, Liu & Smith, "How Language Model Hallucinations Can Snowball," ICML 2024 (arXiv:2305.13534).
**Design consequence**: the thought→thought inheritance rule (reused claims carry their rung), and further support for factored checks — isolation is precisely the condition under which the model can see its own error.

## 29. Citation converts hypothesis into fact

**Finding**: A complete citation-network analysis of one biomedical claim (242 papers, 675 citations, 220,553 supporting citation paths) showed unfounded authority manufactured by citation bias against refuting papers, amplification by papers containing no data, and "the conversion of hypothesis into fact through citation alone" — an information cascade, not an evidence base.
**Source**: Greenberg, "How citation distortions create unfounded authority," BMJ 2009 (339:b2680).
**Design consequence**: the source→source inheritance rule — independence check before counting confirmations; two sources with one origin are one source.

## 30. Models favor their own prior outputs

**Finding**: LLM evaluators score their own generations higher than others' while human annotators rate them equal; out-of-the-box self-recognition is non-trivial, and fine-tuning shows a linear, causal relationship between self-recognition and self-preference strength.
**Source**: Panickssery, Bowman & Feng, "LLM Evaluators Recognize and Favor Their Own Generations," NeurIPS 2024 (arXiv:2404.13076).
**Design consequence**: the turn→turn inheritance rule — re-cite your past self at the rung it earned then, not the confidence it acquired by sitting in the transcript.

# Round 5 findings (2026-07-14 skill-gap-analysis pass — wave-2 verified against primaries; sources per entry. Fuller audit trail in the personal machine's `@research/skill-gap-analysis-2026` workspace only)

## 31. Inverse scaling in test-time compute

**Finding**: Longer reasoning monotonically worsens accuracy on four task classes across Claude/GPT/o3-mini/Qwen: distraction by misleading detail, spurious-correlation amplification, framing overfitting, and confabulation on truthfulness questions.
**Source**: Anthropic, "Inverse Scaling in Test-Time Compute," arXiv:2507.14417 (July 2025).
**Design consequence**: the task-class gate in Calibrating depth — planted frames / misleading detail / bare truthfulness get a short chain plus a rung-3 check, not more thoughts.

## 32. Reasoning training degrades abstention

**Finding**: Reasoning fine-tuning degrades abstention by ~24% on average across 20 frontier LLMs × 20 datasets (unanswerable, underspecified, false-premise, outdated), even in-domain; scale barely helps; scaffolded prompts partially recover it.
**Source**: AbstentionBench, arXiv:2506.09038 (June 2025).
**Design consequence**: clarify-or-abstain is an enforced checklist outcome of the premise audit, never trusted to trained instinct.

## 33. Verbalized confidence is miscalibrated; consistency-weighting repairs it

**Finding**: Single-sample verbalized confidence runs ~98% stated vs far lower accuracy (ECE up to 0.335); aggregating independent samples weighted by answer agreement (CoCoA-class) reaches ECE 0.06–0.08.
**Source**: "Systematic Evaluation of Uncertainty Estimation Methods," arXiv:2510.20460 (Oct 2025).
**Design consequence**: the Conclude rule — a lone self-reported percentage never gates anything; consequential odds come from agreement across the gate's independent derivations.

## 34. Conversational debate fails; independent convergence stands (two lineages)

**Finding**: Multi-agent debate does not reliably beat single-agent self-consistency (conformity + error propagation); independently, expert teams average below their best member by up to 37.6% via integrative compromise. Anonymization reduces conformity bias (IBC 0.608→0.024) without measured accuracy gain.
**Sources**: arXiv:2511.07784; Smit et al. arXiv:2311.17371 (ICML 2024); ICLR 2025 5-framework×9-benchmark evaluation; arXiv:2602.01011 (ICML 2026); arXiv:2510.07517.
**Design consequence**: hardened wording of the gate's no-debate rule — the two lineages share no citations, so this is genuine convergence, not an echo.

## 35. Evaluated, not encoded: monitor-before-generate rubric

**Finding**: Difficulty-estimation before solving + a 4-axis verify rubric (coherence/plausibility/consistency/goal-conduciveness) beat generate-then-critique (75.4% vs 68.4% Self-Refine on GSM8K, Llama-3.1-8B).
**Source**: arXiv:2510.16374 (Oct 2025).
**Design consequence**: none yet — single small-model benchmark, and the challenge gate's named checks already subsume the rubric; revisit if replicated on frontier models.
