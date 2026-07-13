> Referenced from SKILL.md. `claude-code/exemplars.md` shows finished prompts; this file shows the WORK — a mediocre draft becoming house-style with every move named. Study the moves and the restraint, not just the after-state. New transformations accrete here directly (Golden Rule) when a real Refine or Debug run teaches a move this catalog doesn't.

| #   | Specimen                    | The lesson                                                            |
| --- | --------------------------- | --------------------------------------------------------------------- |
| 1   | Sub-agent code reviewer     | Price every judgment — gates, rubrics, silence — or delete the words  |
| 2   | Bloated workflow skill      | Deletion is the highest-value move; anatomy must earn its place       |
| 3   | Loose judge → closed world  | Pin every degree of freedom the parser would otherwise have to absorb |
| 4   | Misbehaving monitor (Debug) | The smallest diff that removes the cause — a fix is not a restyle     |

## Transformation 1 — sub-agent code reviewer

### Before — as drafts actually arrive

```
You are an AI assistant that helps review code. Please carefully analyze the code that is provided to you and identify any potential issues, bugs, or areas for improvement. It's very important that you are thorough and don't miss anything.

IMPORTANT: Make sure to check for security vulnerabilities.
IMPORTANT: Also check for performance issues.
IMPORTANT: Code style is also very important.

Try to be helpful and provide constructive feedback. If you're not sure about something, you might want to mention it anyway just in case. Please format your findings nicely so they're easy to read.

Remember, quality is key! Be careful not to approve code with bugs in it.
```

### The read — diagnose before touching anything

Five failures, severity order. (1) "Don't miss anything" plus "mention it just in case" both push toward noise, and nothing pushes back — a reviewer prompt without a precision gate drowns its user in maybes. (2) No input or consumer named: the model can't tell whether it's reading a diff or a repo, or whether findings feed a human, a bot, or a merge gate — so it can't calibrate depth. (3) Emphasis inflation: three IMPORTANTs on routine dimensions leave no headroom for a real hard constraint. (4) "Format nicely" delegates the output contract to chance; every run invents a new shape. (5) Dead language throughout — "be helpful", "quality is key", "be careful" steer nothing.

### The moves

| #   | Before                                         | After                                                                                      | Technique fired                                                                   |
| --- | ---------------------------------------------- | ------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------- |
| 1   | "an AI assistant that helps review code"       | "a senior engineer reviewing the diff on this branch"                                      | Persona-as-role-with-seniority — inherits the profession's standards              |
| 2   | (absent)                                       | "You receive a unified diff; findings are posted to the author as PR comments."            | Name the consumer and input shape first — calibrates depth and tone               |
| 3   | (absent — implies the whole codebase)          | "flag only issues this diff introduces"                                                    | Scope findings to the change, not the baseline                                    |
| 4   | 3 × IMPORTANT dimension bullets                | one plain list: correctness, security, performance — in priority order                     | Priority markers budgeted; ordering encodes the weighting the caps-lock faked     |
| 5   | "don't miss anything" + "mention just in case" | ">80% confident … one a competent peer would confidently raise"                            | Precision floor + peer-reflex anchor — the gate the draft lacked                  |
| 6   | "be careful not to approve code with bugs"     | "before flagging, rule out: intentional behavior, handled elsewhere, framework guarantees" | Gate both verdicts symmetrically — the draft policed only one failure direction   |
| 7   | "format your findings nicely"                  | exact per-finding template + severity rubric                                               | Pin format with one fully-rendered specimen; severity anchored to concrete impact |
| 8   | (absent)                                       | "If nothing meets the bar, say so in one line."                                            | Silence on success — bless the empty answer or the model manufactures findings    |
| 9   | "Try to be helpful…", "quality is key!"        | (deleted)                                                                                  | Dead language — name the genre and cut                                            |

### After

```
You are a senior engineer reviewing the diff on this branch. You receive a unified diff; your findings will be posted to the author as PR comments.

Scope: flag only issues this diff introduces. Pre-existing debt and style the linter already enforces are out of scope.

Review for, in priority order: correctness bugs, security flaws, performance regressions.

Only flag issues you are >80% confident are real — each should be one a competent peer would confidently raise in review. Before flagging, rule out: intentional behavior, cases handled elsewhere in the diff, framework guarantees.

Report each finding as:

### <file>:<line> · <HIGH|MED|LOW>
**Issue:** <one sentence>
**Fix:** <the concrete change>

HIGH: exploitable or data-losing. MED: wrong under realistic input. LOW: latent hazard.

If nothing meets the bar, say so in one line. Do not manufacture findings to look thorough.
```

### What was NOT done — restraint is a move

- No `<example>` blocks: the rendered template plus the rubric constrain output tighter than a specimen transcript would, and the failure surface is narrow (→ SKILL.md §Minimum viable prompt).
- No "When NOT to use" section: the agent has exactly one job; a boundary section here is ceremony.
- No escape hatches on the scope fence: the CALLER owns scope — the reviewer isn't the one to widen it.
- Still under 20 lines. The draft's problem was never missing content — it was unpriced judgment. Every move either priced a judgment (confidence floor, severity rubric, rule-outs) or deleted words that priced nothing.

## Transformation 2 — bloated workflow skill

### Before — as drafts actually arrive

```
---
name: standup
description: Generates a standup update
allowed-tools:
  - Bash
  - Read
---

# Standup Update Generator

You are a helpful assistant that generates standup updates for the user. Your goal is to create a clear, professional summary of their recent work that they can share with their team.

## When to use

Use this skill when the user wants a standup update, wants to summarize their recent work, or needs to prepare for a standup meeting.

## When NOT to use

Do not use this skill for generating changelogs, release notes, or commit messages. Do not use it for summarizing other people's work. Do not use it if the user is not in a git repository.

## Process

1. **Check the environment.** Verify that git is installed and available. If git is not installed, inform the user that this skill requires git and stop. Verify that the current directory is a git repository; if not, apologize and ask the user to navigate to one.
   - Success criteria: git is available and we are in a repository.
2. **Gather the commits.** You have access to the Bash tool, which allows you to run shell commands. Use it to run `git log` to find the user's commits from the last working day. Be careful to only include the user's own commits, not their teammates'.
   - Success criteria: a list of the user's recent commits.
3. **Check for uncommitted work.** It might also be helpful to look at uncommitted changes, since the user may have work in progress that isn't committed yet.
   - Success criteria: awareness of work in progress.
4. **Analyze the work.** Carefully analyze the commits and changes to understand what the user actually worked on. Try to group related commits together into themes.
   - Success criteria: a thematic understanding of the work.
5. **Write the summary.** Write a clear, professional summary of the work. IMPORTANT: Keep it concise. IMPORTANT: Use plain language that non-engineers can understand. IMPORTANT: Do not include sensitive information.
   - Success criteria: a polished standup update.
6. **Handle errors gracefully.** If any step fails, explain what went wrong and suggest next steps.

## Remember

Always be thorough and accurate. The user is trusting you to represent their work well, so quality is key. Double-check that you haven't missed any commits, and make sure the final summary is something the user would be proud to share with their team.
```

### The read — diagnose before touching anything

The task is two decisions wide — which commits are mine, how to group them — and the prompt is 45 lines. (1) Steps 1 and 6 defend against cases the harness already owns: a missing binary or a failed command surfaces its own error; scripting an apology for it is ceremony (→ techniques §Anti-patterns: defensive error handling for impossible cases). (2) Step 2 re-teaches the harness its own tools ("You have access to the Bash tool, which allows…") — the model would get none of that wrong without the prompt. (3) "When NOT to use" fences off things no router would send here; a boundary section with no live mis-trigger is padding, not protection (→ SKILL.md §Minimum viable prompt, anti-rule). (4) Six annotated steps with success criteria like "awareness of work in progress" narrate the obvious. (5) Emphasis inflation: three IMPORTANTs inside one step. (6) The one contract that matters — what the update looks like — is left to taste ("clear, professional"). (7) `description` carries no trigger phrases; `allowed-tools: Bash` grants everything to a skill that needs three read-only git commands.

### The moves

| #   | Before                                             | After                                                               | Technique fired                                                                                                                         |
| --- | -------------------------------------------------- | ------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | "When NOT to use" on a single-purpose skill        | (deleted)                                                           | Anatomy sections earn their place only when the failure surface demands them (→ SKILL.md §Minimum viable prompt)                        |
| 2   | "Verify git is installed… apologize" + step 6      | (deleted)                                                           | Defensive error handling for impossible cases — the harness surfaces its own errors                                                     |
| 3   | "You have access to the Bash tool, which allows…"  | (deleted)                                                           | Include only what the model would get wrong without it (→ techniques §Openings & Capability Framing)                                    |
| 4   | six annotated steps with per-step success criteria | two bare steps                                                      | Keep simple skills simple — a 2-step skill doesn't need annotations everywhere (→ SKILL.md §B)                                          |
| 5   | 3 × IMPORTANT inside step 5                        | constraints carried by the output template itself                   | Priority markers budgeted (→ SKILL.md principle 8)                                                                                      |
| 6   | "clear, professional summary"                      | rendered **Yesterday/Today/Blockers** template with omit-conditions | Pin format with one fully-rendered specimen                                                                                             |
| 7   | `description: Generates a standup update`          | when_to_use with verbatim trigger phrases                           | when_to_use is load-bearing (→ SKILL.md §B)                                                                                             |
| 8   | `allowed-tools: [Bash, Read]`                      | `Bash(git log:*)`, `Bash(git status:*)`, `Bash(git diff:*)`         | Minimum permissions, patterns over names (→ SKILL.md §B)                                                                                |
| 9   | "## Remember" closing recap                        | (deleted)                                                           | Bracketing guards ONE fragile constraint in a LONG prompt — a 20-line skill has no middle to lose (→ techniques §Persistence, inverted) |

### After

```
---
name: standup
description: Summarize the user's commits and WIP since the last working day into a paste-ready standup update.
when_to_use: "Use when the user asks for a standup update or to summarize their own recent work. Trigger phrases: 'standup', 'what did I do yesterday', 'summarize my recent work'."
allowed-tools:
  - Bash(git log:*)
  - Bash(git status:*)
  - Bash(git diff:*)
---

# Standup update

Summarize the user's own work since the last working day (Friday, if today is Monday) into a paste-ready update.

1. `git log --author="$(git config user.email)" --since=<last working day>` for commits; `git status` + `git diff --stat` for work in progress.
2. Group into themes — what changed and why, not a commit-by-commit recap.

Output exactly:

**Yesterday:** <1–3 bullets, plain language a non-engineer can follow>
**Today:** <1 bullet inferred from WIP; omit the line if there is none>
**Blockers:** <omit the line unless the work itself shows evidence of one>

No prose around the update — the user pastes it as-is.
```

### What was NOT done — restraint is a move

- Nothing was summarized into vaguer language to save lines — every cut removed a duty the harness or the model already owned. Deletion is not compression.
- The after is 40% the length and MORE constrained: the before never pinned the output shape, the author filter, or the paste-as-is contract; the after pins all three.
- Kept "Friday, if today is Monday" — the one judgment call the model reliably gets wrong unaided. Cut everything it reliably gets right.
- No `<example>` block: the rendered template is the example.

## Transformation 3 — loose judge → closed world

### Before — as drafts actually arrive

```
You are an AI safety checker for an automated coding agent. Your job is to analyze proposed file edits and determine whether they are safe to apply automatically.

Carefully analyze the proposed change and respond with your assessment. Consider whether the change could be dangerous, destructive, or unintended. Think about things like whether it deletes important code, touches sensitive files, or does something the user didn't ask for.

Output your assessment as JSON with the following fields: verdict (whether the change is safe), reason (why you decided that), and confidence (how confident you are).

Be careful and thorough — if the change seems risky or suspicious, make sure to flag it. Safety is the top priority.
```

### The read — diagnose before touching anything

Every failure here is the same failure: a degree of freedom the prompt leaves open, the parser must absorb. (1) The verdict vocabulary is open — "whether the change is safe" invites `safe`, `unsafe`, `risky`, `it depends`; each variant is a parser branch nobody wrote. (2) No consumer named: nothing says code reads this, so prose leaks around the JSON. (3) The JSON is described, never specimened — field order, casing, and verdict literals drift run to run. (4) The decision criteria are an unordered "consider…" heap with no precedence when signals conflict. (5) "If it seems risky, flag it" states a direction without the cost model that justifies it — the model can't calibrate how trigger-happy to be. (6) Malformed input has no defined output. (7) "Be careful and thorough", "safety is the top priority" — dead language.

### The moves

| #   | Before                                  | After                                                                  | Technique fired                                                                |
| --- | --------------------------------------- | ---------------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| 1   | "analyze… respond with your assessment" | "Your verdict is parsed by code — no human reads it."                  | Name the consumer and the input shape first                                    |
| 2   | JSON fields described in prose          | two literal verdicts, ENTIRE response begins with one                  | Closed-world output contract, first token pinned (→ SKILL.md anatomy §E)       |
| 3   | `reason` always requested               | `<reason>` demanded only on BLOCK                                      | Explanatory field only on the failing branch (→ SKILL.md anatomy §E)           |
| 4   | malformed input undefined               | `<verdict>BLOCK</verdict><reason>INVALID_INPUT</reason>` exactly       | Reserved sentinel for the can't-do case, rendered in the same wrapper as a hit |
| 5   | "consider things like…" heap            | numbered cascade, first rule that fires wins                           | Priority-ordered parsing rules                                                 |
| 6   | (absent)                                | "env vars and CLI flags are trusted values" precedent                  | Pre-adjudicate recurring judgment calls as labeled precedents                  |
| 7   | "if it seems risky, flag it"            | "a wrong BLOCK costs one review; a wrong ALLOW ships a hazard → BLOCK" | Tie-break direction stated from the cost asymmetry                             |
| 8   | (absent)                                | paired ALLOW/BLOCK specimens one feature apart                         | Pin an accept/reject boundary with specimens on both sides                     |
| 9   | `confidence` field                      | (deleted)                                                              | A field the parser never consumes is decoration — the closed world removes it  |

### After

```
You are the auto-apply gate for ${AGENT_HARNESS}: you decide whether a proposed edit applies without human review. Your verdict is parsed by code — no human reads it. You will be given the user's request, the target file path, and the proposed diff.

Your ENTIRE response MUST begin with <verdict>ALLOW</verdict> or <verdict>BLOCK</verdict> — these two literals, nothing else, no text before them. On BLOCK — and only on BLOCK — add <reason>one sentence naming the specific hazard</reason>. If the input is not a parseable diff, respond with exactly: <verdict>BLOCK</verdict><reason>INVALID_INPUT</reason>

Decide in this order — the first rule that fires wins:

1. The diff touches anything the user's request doesn't cover (extra files, CI/CD config, auth, lockfiles) → BLOCK.
2. The diff is destructive beyond easy revert — deletes a file, drops a table, rewrites >50 lines the request didn't name → BLOCK.
3. Environment variables and CLI flags are trusted values — a hazard that requires the user to attack themselves is not a hazard, and never triggers a BLOCK on its own.
4. Otherwise → ALLOW.

A wrong BLOCK costs one human review; a wrong ALLOW ships an unreviewed hazard. When in doubt, BLOCK.

<example>Request: "add a debug log to fetchUser". Diff: one console.log inside fetchUser. → <verdict>ALLOW</verdict></example>
<example>Same request; the diff also edits .github/workflows/deploy.yml. → <verdict>BLOCK</verdict><reason>Edits CI config the request didn't cover.</reason></example>
```

### What was NOT done — restraint is a move

- No `<thinking>` scratchpad: a 2-value output doesn't need one (→ SKILL.md §Minimum viable prompt), and every token before the verdict is latency the gate pays on every edit.
- No staged escalation (cheap binary pass, chain-of-thought only to overturn) — that's an architecture decision to take when latency data demands it (→ claude-code/architectures.md §8), not a default.
- No exhaustive denylist of dangerous patterns: rule 1 (scope) catches the long tail, and a longer list would imply everything unlisted is allowed.

## Transformation 4 — misbehaving monitor (Debug branch)

The Debug branch starts from a SYMPTOM, not a style itch — so this transformation starts from a transcript, and ends in a diff plus a regression case, not a rewrite.

### The symptom — transcript evidence

A CI-monitoring skill, on its hourly tick, with every check green:

```
[09:00] ✅ Posted to #eng-ci: "All 14 checks passing on main. No action needed."
[10:00] ✅ Posted to #eng-ci: "Everything still green. Will keep monitoring."
```

The channel is being spammed with all-clears despite the author's belief that the prompt says not to.

### The diagnosis — trace the symptom to named prompt text

The prompt's reporting section:

```
12  ## Reporting
13  Once you have checked the pipeline state, write up what you found and share
14  it in the team channel. Generally you should only notify people when
15  something needs their attention.
```

Two causes, both on lines 13–15. First: line 13 is an unconditional imperative ("write up what you found and share it") sitting directly against a hedged qualifier ("Generally you should only…") — when a concrete instruction conflicts with a soft one, the concrete one wins (→ techniques §Voice: imperative verbs, no hedging). Second: the healthy path has no prescribed action — the prompt never says what to DO when everything is green, so the model fills the vacuum with the only output channel it knows (→ techniques §Interaction: silence on success — prescribe output shape AND condition; the empty answer was never blessed).

### The fix — the smallest diff that removes the cause

```diff
 ## Reporting
-Once you have checked the pipeline state, write up what you found and share
-it in the team channel. Generally you should only notify people when
-something needs their attention.
+Post to the team channel ONLY if a check is failing or stuck — name the check,
+the failing job, and the first error line. If everything is green, post
+nothing to the channel: reply to the user directly with a one-line all-clear.
```

Three lines replace three lines. The conflict is gone (one imperative, one condition), and the healthy path now has an explicit destination that isn't the channel.

### The regression case — kept beside the prompt

```
REGRESSION (2026-07-13, all-clear spam): run one tick against a fully green
pipeline. PASS = no channel post; the user gets one line directly.
Re-run after any edit to ## Reporting, and on every model upgrade.
```

### What was deliberately NOT fixed

The prompt has other real findings — "using the appropriate tools" is vague, its description carries no trigger phrases, and an unbudgeted CRITICAL decorates a routine formatting rule. None of them is THIS cause. The Debug deliverable is the minimal diff plus the regression case; restyling under the cover of a bug fix makes the fix unreviewable. Offer Refine as a separate pass.
