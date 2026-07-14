---
name: gigareview
description: Adversarial re-review of everything this session produced — fresh-eyes hunt at the stakes-appropriate bar, live-probe every premise, fix findings, re-run full regression, close with GO/NO-GO.
when_to_use: >
  Use when the user asks to re-review completed session work before relying on it.
  Trigger phrases: "gigareview", "/gigareview", "review it all one more time",
  "are we good to ship/use this", "double-check everything before X", "final pass".
  Distinct from /code-review: that reviews a diff for bugs; this reviews the session's
  whole work-product (code, scripts, skills, configs, docs) against how it will be USED.
  Also the escalation target of /execute-plan step 4 for high-stakes plans.
argument-hint: "[stakes/scope — e.g. 'daily unattended use next week']"
allowed-tools:
  - Agent
  - Bash
  - Edit
  - Glob
  - Grep
  - Read
  - Workflow
  - Write
---

# Gigareview

$ARGUMENTS

Adversarial pass over THIS session's work-product. You built it; now try to break it.
Runs inline — the reviewer needs full session context. Verification vocabulary is
sequential-thinking's ladder: rung 3 = external observation (run it, read it, probe
it), rung 2 = blind re-derivation, rung 1 = re-reading. Cite rungs in findings.

## Goal

An honest GO/NO-GO the user can act on: findings hunted at the stated stakes,
confirmed at rung 3 before any fix, fixed, regressed, residual risks named.

## Steps

### 1. Inventory + bar

List every artifact this session created or modified (code, scripts, skills, configs,
docs — from conversation memory, not just git). Restate the stakes from `$ARGUMENTS` or
the user's message ("dozens of unattended sessions" ≠ "one demo") — the bar for what
counts as a finding. Calibrate like sequential-thinking's stakes × reversibility: a
one-way door gets the full gate even when it looks easy. No stakes stated → assume
daily unattended use (the strictest common case) and say so in the bar statement.

**Success criteria**: A complete artifact list and a one-line bar statement.

### 2. Fresh-eyes hunt

Re-read every artifact end-to-end as a skeptic who didn't write it. Hunt by lens, not
by vibe: **concurrency** (races, locking, double-fire) · **lifecycle** (crashes mid-step,
stale state, restarts, timing windows) · **environment** (arg forms, subcommands, missing
tools, platform quirks, disabled features) · **silent failure** (errors swallowed, paths
that no-op, work that looks done but isn't) · **misuse** (how will real usage differ from
the happy path just tested?).

**Execution**: Scale by stakes — Direct for normal work; for unattended/production
stakes, fan out one agent per lens through the Workflow tool (this instruction is the
Workflow opt-in). Every fan-out agent pins `model: 'opus'` — the hunt is legwork, and
an unpinned agent burns premium tokens (CLAUDE.md model split). Schema-force the
returns (`{findings: [{artifact, failure_scenario, lens, summary}]}`) and give each
brief its scope triad: artifacts it owns, artifacts sibling lenses own, shared
context. Their findings arrive as claims carrying their own assumptions, not as
evidence (sequential-thinking: premise inheritance) — step 3 grades them.

**Success criteria**: Each artifact examined under each lens; findings listed with a
concrete failure scenario each — no "might be an issue" without a trigger. Once
findings outgrow one message or fixes will fan out, keep them in a ledger file
(scratchpad `gigareview-<slug>.md`) that fix agents and a resumed pass can read.

### 3. Verify findings, probe premises, attack the set

Three verifications, all at rung 3:

- **Findings, deterministic first**: route each finding through deterministic
  evidence before any manual probe — compiler, type-checker, existing test,
  static analyzer; 94–98% of LLM false positives die at this gate (2026-07-14 ·
  @research/skill-gap-analysis-2026). Then reproduce what determinism can't:
  run the trigger, hit the path. Reproduced → CONFIRMED; argued only from
  reading → PLAUSIBLE, reported but never fixed on faith. A false positive that
  gets "fixed" injects a regression into working code — this session's own
  fleets ran ~1 in 4 false, and independent benchmarks put the best commercial
  reviewers at 15–50% precision on real bugs.
- **Premises**: every claim the design rests on gets verified against live behavior —
  run the command, read the source, inspect the process. Confident recall is rung 1;
  this session's builds are as unverified as anyone else's.
- **The finding-set**: before anything surfaces, one adversarial pass attacks the
  assembled findings as a whole — duplicates wearing different words, mutually
  contradicting findings, and the strongest refutation of each keeper. A production
  reviewer credits exactly this critique-the-critique stage as its primary
  false-positive mechanism (<1% of surfaced findings marked incorrect, vendor-reported).

**Success criteria**: Each finding marked CONFIRMED (rung 3) or PLAUSIBLE; each
load-bearing premise marked verified-live or reworked; the finding-set survived
its own review.

### 4. Fix + regress

Fix every CONFIRMED finding — fixes route to pinned opus agents (the session model
judges, it does not type patches; trivial one-liners excepted). Then re-run the full
verification the artifact class supports: the complete test suite for code — not only
tests for the new fixes, hardening one path often breaks another; a live invocation
or probe for scripts, skills, configs, and docs, which ship with no suite — the
step-3 probes, re-run against the fixed artifact, are the regression.

**Success criteria**: All CONFIRMED findings fixed or explicitly accepted with a
reason; full suite / probe set green.

### 5. Verdict

Close with: findings fixed (one line each), PLAUSIBLE findings left open, residual
risks accepted (with likelihood and blast radius), a plain GO or NO-GO against the
bar from step 1, and one "would change my mind" line — the observation that would
flip the verdict. For unattended or production bars, add an unanchored second
opinion first: a fresh pinned-opus agent gets the artifacts and the bar — never the
findings or the chain — and its independent verdict is compared; divergence is a
gate failure to resolve, not a footnote.

**Success criteria**: The user can decide to rely on the work from this summary alone.

**Rules**:

- Never soften a NO-GO — an unresolved CONFIRMED finding at the stated stakes blocks the GO.
- Findings in artifacts you didn't build this session get reported, not silently fixed.
- PLAUSIBLE findings are reported, never fixed — a fix without a reproduced failure is a regression risk taken on faith.
- When judging between candidates (severities, competing fixes, borderline GO), swap presentation order and re-judge — position/verbosity/authority biases are large and reverse sign on test-related judging; order-swap is the one validated control (2026-07-14 · @research/skill-gap-analysis-2026).
- A finding class the user judges noise in a repo encodes into that repo's `.claude/` as a suppress rule at the moment of the judgment — never re-litigated per run; retire the rule if it starts eating real findings.
- Periodically audit the reviewer itself: plant a known defect and check the hunt catches it — mutation score, not coverage, is the reliable quality signal for a review process.
