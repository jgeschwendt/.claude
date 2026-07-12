---
name: gigareview
description: Adversarial re-review of everything this session produced — fresh-eyes hunt at the stakes-appropriate bar, live-probe every premise, fix findings, re-run full regression, close with GO/NO-GO.
when_to_use: >
  Use when the user asks to re-review completed session work before relying on it.
  Trigger phrases: "gigareview", "/gigareview", "review it all one more time",
  "are we good to ship/use this", "double-check everything before X", "final pass".
  Distinct from /code-review: that reviews a diff for bugs; this reviews the session's
  whole work-product (code, scripts, skills, configs, docs) against how it will be USED.
argument-hint: "[stakes/scope — e.g. 'daily unattended use next week']"
allowed-tools:
  - Agent
  - Bash
  - Edit
  - Glob
  - Grep
  - Read
  - Write
---

# Gigareview

$ARGUMENTS

Adversarial pass over THIS session's work-product. You built it; now try to break it.
Runs inline — the reviewer needs full session context.

## Goal

Every artifact the session produced holds up under the stated stakes: hidden failure
modes found and fixed, every load-bearing premise verified against live behavior, full
regression green, and an honest GO/NO-GO with residual risks named.

## Steps

### 1. Inventory + bar

List every artifact this session created or modified (code, scripts, skills, configs,
docs — from conversation memory, not just git). Restate the stakes from `$ARGUMENTS` or
the user's message ("dozens of unattended sessions" ≠ "one demo") — the bar for what
counts as a finding.

**Success criteria**: A complete artifact list and a one-line bar statement.

### 2. Fresh-eyes hunt

Re-read every artifact end-to-end as a skeptic who didn't write it. Hunt by lens, not
by vibe: **concurrency** (races, locking, double-fire) · **lifecycle** (crashes mid-step,
stale state, restarts, timing windows) · **environment** (arg forms, subcommands, missing
tools, platform quirks, disabled features) · **silent failure** (errors swallowed, paths
that no-op, work that looks done but isn't) · **misuse** (how will real usage differ from
the happy path just tested?).

**Execution**: Scale by stakes — Direct for normal work; for unattended/production
stakes, additionally fan out parallel subagents (one lens each, self-contained
briefings) and verify their findings yourself before acting.

**Success criteria**: Each artifact examined under each lens; findings listed with a
concrete failure scenario each — no "might be an issue" without a trigger.

### 3. Probe premises live

Every claim the design rests on gets verified against live behavior — run the command,
read the source, inspect the process. Confident recall is not verification; this
session's builds are as unverified as anyone else's.

**Success criteria**: Each load-bearing premise marked verified-live or reworked.

### 4. Fix + regress

Fix every confirmed finding. Then re-run the FULL regression suite from the build
phase — not only tests for the new fixes; hardening one path often breaks another.

**Success criteria**: All findings fixed or explicitly accepted with a reason; full
suite green.

### 5. Verdict

Close with: findings fixed (one line each), residual risks accepted (with likelihood
and blast radius), and a plain GO or NO-GO against the bar from step 1.

**Success criteria**: The user can decide to rely on the work from this summary alone.

**Rules**:

- Never soften a NO-GO — an unresolved finding at the stated stakes blocks the GO.
- Findings in artifacts you didn't build this session get reported, not silently fixed.
