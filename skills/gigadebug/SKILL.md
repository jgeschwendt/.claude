---
name: gigadebug
description: Root-cause an observed failure — reproduce first, fan out competing falsifiable hypotheses to opus investigators, eliminate on differential evidence, fix the cause, and ship the repro as a permanent regression test.
when_to_use: >
  Use when something is observably broken and the cause is unknown — a
  failing test, a production error, wrong output, "worked yesterday".
  Trigger phrases: "gigadebug", "/gigadebug", "hunt this bug down", "find
  the root cause", "why is this failing". The escalation target for bugs
  /gigarefine and /gigaredesign report-and-leave. Distinct from
  /gigasweep (no symptom — proactive sweep), /code-review (a diff), and
  /gigareview (this session's work). Needs a symptom: no observed failure →
  /gigasweep is the hunt without one.
argument-hint: "[symptom — error text, failing test, repro steps, 'X broke after Y']"
allowed-tools:
  - Agent
  - AskUserQuestion
  - Bash
  - Edit
  - Glob
  - Grep
  - Read
  - Workflow
  - Write
---

# Gigadebug

$ARGUMENTS

An observed failure in; a root cause, a minimal fix, and a permanent
regression test out. Sequential-thinking discipline throughout: hypotheses
are eliminated by rung-3 evidence (the verification ladder — rung 3:
external observation, run/probe it; rung 2: blind re-derivation; rung 1:
re-reading), never adopted by plausibility. The
session model reasons and judges; pinned opus agents run probes and type
the fix.

## Goal

The failure reproduced on demand, its cause named at the level that
explains ALL the evidence, fixed minimally at the cause site, the repro
promoted into the suite, and a report saying why the defect existed and why
nothing caught it.

## Steps

### 1. Reproduce

- Turn the symptom into a minimal, deterministic repro command — smallest
  input, fewest steps. Flaky counts too: N runs and a measured failure
  rate IS a repro.
- Can't reproduce → that is the finding: report the missing observability
  (logging, seed capture, state dump) and stop — a fix without a repro
  can't be verified, and a passing suite proves nothing about it.
- Note the suite's status BEFORE touching anything; pre-existing reds are
  context (or the bug's siblings) — record, don't absorb.
- Unattended with no symptom in `$ARGUMENTS` → stop and report.

**Success criteria**: a command that fails on demand (or a measured rate),
recorded in the ledger (scratchpad `gigadebug-<slug>.md`).

### 2. Evidence before hypotheses

- Gather facts deterministically first: full error + stack, the failing
  path's code, `git log` over the implicated files, environment deltas.
- "Worked before" + a known-good ref → `git bisect run <repro>` NOW —
  bisect is the highest-value instrument available and often ends the hunt
  alone.
- Write the fact list into the ledger BEFORE hypothesizing — hypotheses
  formed before the facts anchor on the first plausible story.

**Success criteria**: fact list + bisect verdict (or why bisect doesn't
apply) in the ledger.

### 3. Hypothesis fleet — generate, differentiate, eliminate

- Generate competing root-cause hypotheses in-session. Each must be
  falsifiable: state what it PREDICTS that the others don't — a hypothesis
  with no discriminating prediction is a vibe, not a candidate.
- Fan out one pinned-opus investigator per hypothesis through the Workflow
  tool (this instruction is the Workflow opt-in), schema-forced:
  `{hypothesis, prediction, probe, observed, verdict: supports|refutes|inconclusive, evidence}`.
  Each brief carries the repro command, the fact list, and ONLY its own
  hypothesis — independent investigation, no anchoring on siblings.
  Investigators are read-only: instrument, log, run — never "try a fix to
  see" (a tree of speculative fixes destroys the evidence).
- Judge by elimination: a hypothesis survives only when its discriminating
  prediction was OBSERVED and its rivals' were not (differential
  diagnosis, rung 3). Inconclusive → sharpen the probe, re-dispatch once.
  All refuted → the hypothesis set was wrong; return to step 2 with the new
  evidence — that loop is the method, not a failure.
- Multiple survivors explaining different parts of the evidence → suspect
  multiple bugs sharing one symptom: split the repro, hunt them separately.

**Success criteria**: exactly one cause per repro, with its observed
discriminating evidence in the ledger.

### 4. Fix and prove

- Minimal fix at the CAUSE site (not the symptom site), typed by a pinned
  opus agent under the execute-plan executor contract — DONE requires
  executed verification with its output in the return; read
  `~/.claude/skills/execute-plan/SKILL.md` step 2 when composing the brief. The fix must make
  the repro pass with the full baseline suite still green — needing an
  unrelated test weakened means a symptom got treated.
- Promote the repro to a permanent regression test named after the cause —
  a bug without a pinned regression returns.
- Re-run everything: repro green, suite green.

**Success criteria**: repro passes, suite green, regression test in the
tree.

### 5. Report

The cause (one paragraph — mechanism, not blame), the eliminated
hypotheses one line each (negative results are the reader's map), the fix,
why nothing caught it (test gap? observability gap? — and where that gap
got encoded), residual doubts.

## Rules

- No fix without a repro; no CONFIRMED cause without observed
  discriminating evidence — plausible-and-unfalsified stays PLAUSIBLE and
  is reported as such.
- Read-only until step 4 — investigation never mutates the tree.
- Bisect before fleets whenever history applies — deterministic beats
  parallel speculation.
- Every `agent()` call pins `model:`. The session model generates and
  eliminates hypotheses; it types nothing but the ledger and trivial probe
  one-liners.
- Cause in a dependency/platform, not this repo → report with upstream
  evidence; a workaround ships only with the user's sign-off (it's a
  contract change).
