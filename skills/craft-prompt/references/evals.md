> Referenced from SKILL.md — the eval-and-regression doctrine: how a prompt proves it works, keeps working, and survives model upgrades. Load it at any ship gate (Save / Apply fixes), when the user asks "how do I know this prompt is good", and during Debug when a fix needs a regression case. SKILL.md §Stress-testing supplies the adversarial test menu; this file supplies the machinery around it.

## The stance

A prompt is a hypothesis about model behavior; reading it is not evidence. Improvement is empirical, not aesthetic — the loop Anthropic itself uses for tools and skills: run the prompt on representative real tasks, read the transcripts, fix what the transcripts show, re-run. Claude-optimized rewrites seeded with failure transcripts beat hand-polished ones on held-out evals, so the transcript is not just diagnosis — it is the raw material for the rewrite. (per Anthropic writing-tools-for-agents + agent-skills posts, verified 2026-07-13)

Match rigor to failure surface, same rule as prompt length. A personal one-shot helper earns a handful of kept regression cases; a judge gating merges earns a scored suite that runs on every edit. The unforgivable middle: a load-bearing prompt with zero kept cases, re-validated by vibes after every change.

## The regression file

Every observed failure becomes a named case kept beside the prompt, not in your memory of it. Minimum viable shape — one markdown file (`<prompt-name>.regressions.md`) in the prompt's directory:

```markdown
## R3 — posts all-clear despite silence rule (2026-07-11 · transcript excerpt)

INPUT: (the exact invocation / argument / injected state that failed)
EXPECT: no Slack post; one-line "all healthy" to the user only
GOT-BEFORE-FIX: posted "all sessions healthy ✓" to #alerts
RULE UNDER TEST: SKILL.md "Silence on success" line
```

- **The input is verbatim, not paraphrased.** A paraphrase tests your summary of the bug, not the bug.
- **EXPECT states observable behavior** — output shape, tool called or not called, silence — never "handles it correctly".
- **Name the rule under test** so when the prompt is refactored, the case follows the rule instead of going stale.
- Cases accrete; they are deleted only when the rule they test is deliberately removed. A prompt that doesn't carry its failure history re-learns the same lessons.

Re-run the set: after every edit to the prompt, and on every model upgrade — no exceptions for "trivial" edits; regressions come disproportionately from edits believed trivial.

## Desk checks vs live runs

Two tiers, and honesty about which one you ran:

- **Desk-checkable** (read the prompt against the case): routing determinism, empty-argument handling, contract completeness, internal contradictions, no-good-answer paths. Run these at every ship gate — they cost minutes.
- **Live-only** (needs a real session): triggering rates, multi-turn drift, compaction survival, adversarial input, actual tool-call behavior. If you ship without these, say so where the next editor will see it — _"known untested for adversarial input"_ beats silent uncertainty.

A desk check can prove a prompt broken; only a live run can prove it working.

## LLM-as-judge, for grading prompt outputs

When the regression suite outgrows eyeballing, a judge model grades outputs. The judge prompt itself follows SKILL.md anatomy §E (closed-world verdicts, pinned first token, tie-break from cost asymmetry) — plus the biases specific to judging:

- **Anchor to a rubric, not to taste.** Score against enumerated, observable criteria ("cites file:line for every claim — yes/no"), never "rate quality 1–10"; unanchored scales drift run to run and compress toward the top.
- **Prefer pairwise over absolute** when comparing prompt variants — "which output better satisfies rule X" is more reliable than two absolute scores; randomize A/B order per trial, judges favor a fixed position.
- **Verbosity is not quality; force the judge to say so.** Longer outputs win by default — add the rule: _"a longer answer is not better; judge only against the rubric."_
- **Never let a model judge its own output as the sole gate** — self-preference is measurable; use a different model or pair the judge with one deterministic check.
- **Give the judge the failure catalog, not just the success criteria.** A judge that has seen the named failure modes (fabricated citation, dropped constraint, format drift) catches them; one shown only the happy path grades everything PASS.
- One deterministic assertion (regex on the verdict token, schema validation, exit code) backs every judge — the judge grades the gray zone, the assertion catches the flagrant.

## The transcript-driven refine loop

For the Debug branch and any refine where the symptom came from a live run:

1. **Reproduce** — run the kept regression input, confirm the failure is real and current.
2. **Read the transcript, not the summary of it.** The failure's mechanism is in what the model actually saw and emitted: which rule it quoted, which it never mentioned, where injected context landed relative to the instruction it overrode.
3. **Fix with the smallest diff that removes the cause**, per the Debug branch contract.
4. **Seed a rewrite from evidence when the diff isn't obvious:** hand the model the prompt plus the failing transcript and ask what in the prompt produced the behavior — a model reading a real transcript outperforms a model asked to "improve" a prompt in the abstract. The output is a proposal; the regression run is the verdict.
5. **Re-run the full set** — the new case and all prior ones. A fix that breaks an older case is a conflict between rules, which placement will not arbitrate (→ SKILL.md principle 12); resolve the conflict in the text.

## Model-upgrade protocol

Prompt robustness is model-version-dependent; an upgrade is a silent edit to every prompt you run. On each model change:

1. Re-run every regression file before trusting prior behavior.
2. **Expect the failure direction to flip.** Emphasis written to fix undertriggering on older models (CRITICAL, MUST, "if in doubt, use the tool") overtriggers on newer, more instruction-responsive ones. The upgrade fix is usually _removing_ aggressive language, not adding it. (per Anthropic prompting best-practices, verified 2026-07-13)
3. Audit surviving ALL-CAPS/IMPORTANT markers as suspected overtrigger sources, not as proven necessities — each was calibrated against a model that no longer runs.
4. Watch the trigger-rate symptoms both ways: a skill that suddenly fires on near-misses, a tool invoked for tasks it shouldn't own → over-steering; the old under-fire symptoms → the prompt truly needed the emphasis, keep it.
5. Record the upgrade and its verdicts in the regression file — the next upgrade starts from evidence instead of folklore.
