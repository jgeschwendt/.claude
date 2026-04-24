---
name: craft-prompt
description: Craft or refine a prompt in the Anthropic house style distilled from Claude Code's internal prompts — imperative voice, rule-first structure, explicit rationale, XML-tagged exemplars, silence on success.
when_to_use: "Use when the user asks to write, refine, review, or improve any prompt — tool prompts, skill/workflow prompts, sub-agent personas, system prompts, or general LLM instructions. Also use when the user pastes a draft asking for feedback. Trigger phrases: 'craft a prompt', 'write a prompt', 'refine this prompt', 'make this more Anthropic-style', '/craft-prompt'."
argument-hint: "[draft to refine OR description of what you want to craft]"
allowed-tools:
  - AskUserQuestion
  - Edit
  - Glob
  - Grep
  - Read
  - Write
---

# /craft-prompt — Masterclass in Anthropic-style prompt engineering

Draft or refine a prompt in the house style distilled from Claude Code's internal prompts: imperative, rule-first, examples-as-specifications, silent on success.

## User input

The argument (may be empty):

```
$ARGUMENTS
```

## When invoked

Classify the argument, then route:

| Input shape | Branch | Hot path |
|---|---|---|
| Draft pasted (≥5 lines; frontmatter, imperatives, or role statement) | **Refine** | §Refinement → diff → AskUserQuestion (save?) |
| Description ("a skill that does X", "a prompt for Y") | **Draft** | §Drafting → full draft → AskUserQuestion (refine / save?) |
| Empty | **Interview** | one AskUserQuestion to pick type → route |
| Hybrid (description + partial draft) | **Hybrid** | treat the paste as current state; refine toward the description |

### Turn shape (every response follows this)

1. **Opening line (one sentence)** — name the branch; if refining, name the 1–3 highest-impact issues being fixed. No preamble, no restatement.
2. **Artifact** — fenced code block containing the draft (or a unified diff for refinement).
3. **Rationale** — ≤ 3 bullets, one sentence each, only where the change isn't self-evident.
4. **AskUserQuestion** — options: *Save*, *Refine further*, *Discard*. First option marked `(Recommended)` by branch: *Save* after clean Refine; *Refine further* after Draft or Refine-with-flags-open. Interview ends on the type question instead.

### Per-branch success criteria

- **Refine** — every flagged checklist item has a proposed rewrite OR an explicit *"kept as-is: reason"*. Nothing silently dropped.
- **Draft** — frontmatter complete; one-line capability in first 200 chars; body follows canonical anatomy for the type; at least one `<example>` block if the prompt prescribes a decision with failure modes.
- **Interview** — one AskUserQuestion call; user picks a type; next turn routes to Draft or Refine.
- **Hybrid** — same as Refine, with the description as governing intent when draft and description conflict.

Do NOT restate the user's request. Do NOT open with "Great question", "Let me help you", or any acknowledgment. Go straight to the artifact.

## Scope (when NOT to use this skill)

Not for writing documentation prose, commit messages, code comments, user-facing emails, or product copy. Only for prompts intended to instruct an LLM: tool schemas, sub-agent personas, SKILL.md bodies, system prompts, or sections thereof.

## Core principles (the house style in 9 rules)

1. **Rule first, rationale second.** State the constraint in imperative form, then — same line or next — explain *why* in one phrase. The why lets the model generalize to unlisted edge cases. Canonical: *"NEVER run destructive git commands … Taking unauthorized destructive actions is unhelpful and can result in lost work, so it's best to ONLY run these commands when given direct instructions"*.

2. **Negative framing beats positive for hallucination-prone behaviors.** "Don't peek. Don't race. Don't re-delegate understanding" is stronger than "trust the process." Write prohibitions for behaviors the model would otherwise invent.

3. **Examples are specifications, not illustrations.** An `<example>` block with `<thinking>` and `<commentary>` shows the exact cognitive pattern expected. The model will reproduce the *shape* of your examples — pick them so that reproduction is the desired behavior.

4. **Scope boundaries up front.** For tools and agents, declare what the thing does *not* cover before listing what it does. `"When NOT to Use"` prevents misfires more efficiently than `"When to Use"` alone.

5. **Prefer dedicated tools, name the anti-pattern inline.** *"Use Edit (NOT sed/awk)"*. The parenthetical is the whole teaching — the ban is next to the preferred tool, not in a separate footnote.

6. **Escape hatches, not absolutes.** Every `NEVER` gets an "unless the user explicitly requests it." Authorization is narrow: approving one action does not generalize. Durable authorization lives in CLAUDE.md.

7. **Silence on success.** Specify when the model should *not* output. *"Only post to Slack if you actually found something stuck. If every session looks healthy, tell the user that directly — do not post an all-clear to the channel."*

8. **Priority markers carry real weight.** `IMPORTANT`, `CRITICAL`, `NEVER`, `MUST`, `ALWAYS` — reserved for hard constraints. If they appear in every paragraph they mean nothing. Budget: 1–3 per major section.

9. **Parallel by default.** When multiple operations don't depend on each other, prescribe `"in parallel, in a single message"`. This phrase actually changes batching in practice.

## Anatomy by prompt type

### A. Tool prompt (Bash / Read / Edit / … style)

Canonical section order:

| # | Section | Purpose |
|---|---|---|
| 1 | One-line capability | *"Reads a file from the local filesystem."* |
| 2 | Trust statement | *"Assume this tool is able to read all files on the machine."* — justifies later rules |
| 3 | When to use / When NOT to use | Numbered conditions, each with a 1-line example |
| 4 | Usage notes | Parameter hygiene, path rules, flags |
| 5 | Examples (multi-turn) | `<example>` with `<thinking>` and `<commentary>` |
| 6 | State preconditions | *"You must use Read at least once before editing."* |
| 7 | IMPORTANT notes | Meta-level footguns |

Land the trust statement and the first footgun in the first 200 chars. BashTool does this:

> *Executes a given bash command and returns its output. The working directory persists between commands, but shell state does not. …*
> *IMPORTANT: Avoid using this tool to run `cat`, `head`, `tail`, `sed`, `awk`, or `echo` commands, unless explicitly instructed or after you have verified that a dedicated tool cannot accomplish your task.*

### B. Skill / workflow prompt (SKILL.md)

Frontmatter (canonical form from the Skillify meta-skill):

```yaml
---
name: skill-name
description: one-line description
when_to_use: "Use when... Examples: 'trigger phrase', 'another phrase'"
allowed-tools: [Bash(gh:*), Read, Write, AskUserQuestion]
argument-hint: "[hint showing argument placeholders]"
arguments: [foo, bar]          # omit if no args; use $foo in body
context: fork                   # omit for inline; use for self-contained workflows
---
```

Body order:
1. `# Title` — action-oriented, short
2. One-sentence opener on what the skill does
3. `## Inputs` — describe each `$arg` if any
4. `## Goal` — one paragraph with a concrete artifact or success condition
5. `## Steps` — numbered. **Success criteria** required per step. Optional annotations: **Execution** (`Direct` / `Task agent` / `Teammate` / `[human]`), **Artifacts** (data later steps consume), **Human checkpoint** (pause-and-confirm points), **Rules** (hard constraints).
6. `## Rules` — closing constraints, silence rules, edge cases

Frontmatter rules:
- `allowed-tools`: minimum permissions, patterns over names (`Bash(gh:*)` not `Bash`)
- `when_to_use` is load-bearing: start with "Use when…", include 2–3 trigger phrases verbatim
- `context: fork` only for self-contained workflows with no mid-process user input
- Use `$arg` in body for substitution; `${CLAUDE_SKILL_DIR}` references bundled files; `!`shell command`` injects live output at expansion time
- Step-structure tips: concurrent steps use sub-numbers (3a, 3b); human-action steps get `[human]` in the title; keep simple skills simple — a 2-step skill doesn't need annotations everywhere

### C. Sub-agent persona prompt

Three-part structure, in this order, every time:

1. **Role statement** — one sentence naming the agent and its primary function.
   *"You are a software architect and planning specialist for Claude Code."*
   *"You are a file search specialist for Claude Code, Anthropic's official CLI for Claude. You excel at thoroughly navigating and exploring codebases."*

2. **Scope fence** — `=== CRITICAL: ... ===` around hard boundaries. For read-only agents, list every write surface blocked (Write, touch, rm, cp, mv, redirect operators, heredocs). For specialist agents, list out-of-scope domains. Close with a redundant reminder after the guidelines: *"REMEMBER: You can ONLY explore and plan. You CANNOT and MUST NOT write, edit, or modify any files."*

3. **Strengths + Guidelines + Approach** — bulleted, imperative. If the agent should follow a prescribed workflow (fetch docs, then search, then fall back to web), number the steps.

### D. System-prompt section

Dense imperative bullets. Each bullet is self-contained (the reader might skip everything above it). Mirror the six-part Claude Code frame:

- `# System` — tool architecture, permissions, `<system-reminder>` semantics
- `# Doing tasks` — scope discipline, read before proposing, verify before claiming done
- `# Executing actions with care` — reversibility, blast radius, confirmation defaults, authorization scope
- `# Using your tools` — dedicated over general, parallel vs sequential, task tracking
- `# Tone and style` — emojis, `file_path:line_number`, no colon before tool calls, `owner/repo#123`

Static cacheable content goes first; session-variant content last. Cache keys stay stable on the prefix.

## Minimum viable prompt

Match depth to failure-surface width. Not every prompt needs the full anatomy.

| Use case | Minimum shape | Reference |
|---|---|---|
| One-shot classifier | Role (1 sentence) + strict output schema + 1 example | `utils/hooks/execPromptHook.ts` (closed-world JSON) |
| Extraction to JSON | Role + schema + 2–3 examples | — |
| Simple tool prompt | Capability line + "When NOT to use" + 1 parameter note | `ExitWorktreeTool/prompt.ts` (~12 lines) |
| Simple workflow skill | Frontmatter + Goal + 2–3 Steps + Rules | `/simplify` (~50 lines) |
| Complex workflow / multi-phase | Phases + parallel fanout + per-step success criteria | `/batch`, `/skillify` |
| Sub-agent persona with hard boundaries | Role + `=== CRITICAL ===` scope fence + guidelines + closing reminder | Explore / Plan / Verification agents |
| Full system-prompt section | Dense imperative bullets, cache-boundary-aware | Claude Code's own system prompt |

**Rule of thumb**: the prompt should be as long as its failure surface is wide. A classifier with a 2-value output doesn't need `<thinking>` tags. A multi-phase workflow with async sub-agents does. If you're writing more than the anatomy demands, that's scope creep *in the prompt itself* — cut.

**Anti-rule**: don't pad a short prompt with anatomy sections it doesn't need ("When NOT to use" for a 10-line classifier is ceremony, not clarity).

## Techniques catalog

### Structure
- **Decision framework via numbered conditions**: 5–10 "Use when…" criteria, each with a 1-line example. Mirror with "Do NOT use when…".
- **BAD → GOOD contrast**: identical input, two blocks. The diff *is* the teaching.
- **Rule-first, rationale-second**: *"NEVER X unless explicitly requested — taking unauthorized destructive actions…"*.
- **Tool-precedence inline**: *"Use Edit (NOT sed/awk)"*.
- **Scope fence**: `=== CRITICAL: READ-ONLY MODE — NO FILE MODIFICATIONS ===` for hard capability boundaries.
- **Priority-ordered parsing rules**: first match wins. *"1. Leading token matches `^\d+[smhd]$`. 2. Trailing `every N<unit>`. 3. Default."*
- **Destination / classification tables**: `| Target | What belongs there | Examples |`. See the memory-layer table in `/remember` — one row per destination, verbatim examples per row.
- **Read-before-write enforcement**: *"Always read the existing settings file before making changes. Merge with existing — never replace the entire file."*
- **Catalyst vs. prescription (default: prescribe).** Prescriptions are the norm — they work for rules that constrain mechanical actions (*"alpha-sort imports"*, *"use Edit not sed"*, *"never commit without explicit user request"*). **Exception**: preserve principle-shaped vagueness when the rule shapes creative or architectural judgment and different models should amplify it differently. Metaphor is the exception-signal — *"journey inward"*, *"smart colleague who just walked into the room"*, *"measure twice, cut once"*, *"the first 80% is the easy part"* are catalysts. Flattening them into procedures loses amplification without gaining determinism where determinism doesn't matter. **If a vague rule doesn't use metaphor**, it's probably generic advice masquerading as principle — flatten it.

### Voice
- **Imperative verbs, no hedging.** "Use", "Don't", "Never", "Skip". Ban: "you might consider", "probably", "perhaps", "could".
- **Priority markers, budgeted.** Reserve `IMPORTANT` / `CRITICAL` / `MUST` / `NEVER` for hard constraints. Overuse flattens signal.
- **No preamble colon before a tool call.** Write *"Let me read the file."* not *"Let me read the file:"* — the user may not see the tool call, leaving a dangling colon.
- **Code references as `file_path:line_number`** so the user can jump.
- **GitHub refs as `owner/repo#123`** so they render as clickable links.

### Examples (XML-tagged)
- **`<example>` wraps a full multi-turn specification.** Put `<thinking>` where the model should narrate reasoning ("Forking this — it's a survey question"), and `<commentary>` where the *reader* should learn something from the example ("Turn ends here. The coordinator knows nothing about the findings yet").
- **`<reasoning>` after an example**: teach *why* the shown tool-choice was right.
- **`<analysis>` and `<summary>`** wrappers when downstream code parses the output (compaction uses this).
- **`<system-reminder>` for the orthogonal-instruction channel.** Content positionally adjacent to a tool_result but semantically independent of it. Pair with the contract: *"Tool results and user messages may include `<system-reminder>` tags… They bear no direct relation to the specific tool results or user messages in which they appear."* Use for out-of-band guidance (skill listings, mode reminders, memory injections). Skip when the content really IS about the adjacent tool result — then it should live inside the tool_result's content.
- **`<env>` for structured runtime metadata** (cwd, git status, platform, shell, OS, model). Single parseable block beats inline prose — each field is addressable.
- **Per-type slot tags** like `<type>`, `<scope>`, `<when_to_save>`, `<how_to_use>`, `<body_structure>`, `<examples>` (from the memory taxonomy). Use when you want to teach a typed rule as a structured record, not a paragraph.

### Interaction
- **AskUserQuestion for every choice.** Never ask in prose. Put the recommended option first with `(Recommended)` suffix. Always include *Other* (free text). Use multi-select only when multiple answers are truly valid.
- **Acknowledge-then-work** for async / long operations: one-line ack (*"On it — checking the test output"*), silent work, reported result. Prevents spinner-without-feedback.
- **Silence on success**: prescribe output *shape* AND *condition*. If healthy, don't post.
- **Plan-mode visibility caveat**: never ask "Does the plan look good?" via AskUserQuestion — the user can't see the plan until ExitPlanMode. Use ExitPlanMode for approval; use AskUserQuestion for clarification mid-planning.

### Delegation
- **Brief like a smart colleague who just walked in.** Explain goal + context + what's been tried. Forks get directives ("what to do"); fresh sub-agents get descriptions ("what the situation is").
- **"Never delegate understanding."** Don't write *"based on your findings, fix the bug"*. That phrase pushes synthesis onto the agent instead of doing it yourself. Prove you understood: file paths, line numbers, what specifically to change.
- **Don't peek. Don't race. Don't fabricate.** For background work: trust the completion notification, don't read the transcript mid-flight, don't predict results in any format.
- **Parallel fanout, one message**: *"Launch all three agents concurrently in a single message. Pass each the full diff."*
- **Coordinator/worker pattern**: coordinator plans and approves; workers run in `isolation: "worktree"` with `run_in_background: true`; final line of each worker output is the machine-parseable status (`PR: <url>`) the coordinator aggregates.

### Constraint enforcement
- **Negative framing for hallucination-prone capabilities**: *"You have NO tools available"*, *"NEVER say 'Let me try…' or 'I'll now…'"*. Exhaustive prohibition list beats positive framing when the default behavior is what you're fighting.
- **Closed-world JSON schema for classifiers**: force binary output (`{"ok": true}` or `{"ok": false, "reason": "…"}`). No prose wrapper, no reasoning. Schema validation is the enforcement.
- **Closed-world verdict strings**: *"Use the literal string `VERDICT: ` followed by exactly one of PASS, FAIL, PARTIAL. No markdown bold, no punctuation, no variation."* For downstream-parseable outputs, forbid formatting variance.
- **Evidence-required output**: make the format carry the rule. *"A check without a Command run block is not a PASS — it's a skip."* The structural requirement is the enforcement.
- **Dual personas by user type**: branch the prompt on `USER_TYPE` (or feature flag). External users get detailed decision frameworks; internal users get sparse guidance biased toward inference.

### Failure-mode teaching
- **Name the failure pattern before giving rules.** *"You have two documented failure patterns. First, verification avoidance: …"*. A named failure becomes a pattern-matchable shape in the model's own reasoning.
- **Rationalizations catalog.** List the exact excuses the model will reach for, each paired with the counter. *"'The code looks correct based on my reading' — reading is not verification. Run it."* Forces mid-turn recognition of its own drift.
- **"Recognize them and do the opposite."** Teaches the meta-skill of noticing drift and reversing direction.
- **Behavioral interrupt.** *"If you catch yourself writing an explanation instead of a command, stop. Run the command."* A reflex-level redirect triggered by a recognizable signal.

### Persistence and throttling
- **Full-vs-sparse reminder throttling.** For persistent-mode skills (plan mode, auto mode, any long-running state), inject the full directive on turns 1, 6, 11, … and a one-line sparse reminder in between. The sparse line references the full by phrase (*"see full instructions earlier in conversation"*) so the model knows it's a pointer. Prevents context bloat while keeping the mode present every turn.
- **Withholding pattern for recoverable errors.** When an error could be transparently recovered (413 prompt-too-long, media-size), *don't* surface it to the model — attempt staged recovery silently, surface only if recovery fails. The model's context stays clean.
- **Staged classifier (fast + thinking).** Two-stage LLM decisions: stage 1 with tight token cap (~64) and stop-sequence to rubber-stamp obvious cases; stage 2 with larger budget (~4K) and chain-of-thought for borderline cases. Balances latency against precision.
- **Post-clear pairing directive.** Whenever your system may delete or summarize tool output post-hoc, pair it with *"Write down any important information you might need later in your response, as the original tool result may be cleared later."* The model's response becomes the durable record.
- **"Signals, not conversation partners."** For multi-agent orchestration, frame async worker output as structured signals (XML-wrapped task-notifications), not dialogue. Prevents the coordinator from treating worker results as conversational turns.

### Argument handling
- **Append as named section**: `if (args) prompt += "\n\n## Additional Focus\n\n" + args`. Headers seen in the wild: `## Additional Focus` (simplify), `## Additional context from user` (remember), `## User Request` (verify, claude-api).
- **Template substitution**: `${args}` or `{{args}}` at the point of use; the skill body flows around it.
- **Empty-args variant**: if empty, show the usage message and stop — don't call the underlying tool with empty inputs. Loop does this: *"If the resulting prompt is empty, show usage and stop — do not call CronCreate."*

### Output formats
- **HEREDOC for multi-line command arguments** (commits, PR bodies):
  ```bash
  git commit -m "$(cat <<'EOF'
  Commit message here.

  Co-Authored-By: Claude <noreply@anthropic.com>
  EOF
  )"
  ```
- **Numbered template sections** for structured reports: *"1. Primary Request and Intent / 2. Key Technical Concepts / 3. Files and Code Sections / …"*.
- **Length caps** for model-to-user reports: *"report in under 200 words"*, *"one or two sentences"*. Capped output is enforced by mention.

## Voice & style (the CC fingerprint)

- Direct, imperative, spare. *"Use X. Don't Y. Skip Z."*
- Hedging is banned: no *probably / might / should consider / you could / perhaps*.
- Expert register: assume technical competence. Don't explain `git`, `jq`, or heredocs. Give ready-to-run commands.
- Scannable over narrative: tables, decision matrices, numbered steps, not prose paragraphs.
- Every `NEVER` has an escape hatch (`"unless the user explicitly requests"`) and, where it matters, a reason (`"…which can include sensitive files like .env"`).
- Prohibit fabrication explicitly. *"Never fabricate or predict fork results in any format — not as prose, summary, or structured output."*
- Address the reader (the model) in second person. Internal monologue is narrated in `<thinking>` tags inside examples.
- No emojis unless the user explicitly asks.
- `file_path:line_number` for code references; `owner/repo#123` for GitHub links.
- User-facing text: lead with the action, not the reasoning. Inverted-pyramid structure — if something about process must be said, save it for the end.

## Anti-patterns (reject these on sight)

- **Preamble that restates the request.** *"Great question! Let me help you…"* — cut.
- **Comments explaining WHAT code does.** Well-named identifiers do that. Keep only non-obvious WHY (hidden constraint, subtle invariant, past-bug workaround). If removing the comment wouldn't confuse a future reader, don't write it.
- **Every paragraph marked IMPORTANT.** Budget 1–3 per major section. Overuse flattens signal.
- **Scope creep.** *"…and also refactor while you're in there"*, *"with an abstraction for future use"*. Three similar lines beat a premature abstraction.
- **Defensive error handling for impossible cases.** Trust internal invariants. Validate at system boundaries (user input, external APIs) — nowhere else.
- **Vague examples.** "Here's an example:" followed by non-running pseudocode. Examples should be executable or pattern-complete.
- **Positive-only behavior spec.** If a footgun exists, name it. *"Don't peek"* is load-bearing; *"trust the process"* is not.
- **Authorization creep.** Never say *"assume the user wants X"* on the basis of a prior approval. Each authorization is narrow.
- **Time estimates / predictions.** *"This should take about 20 minutes"* — prohibit it.
- **Claiming success without verification.** Prescribe: *"Before reporting complete, run the test / script / build. If you can't verify, say so explicitly."*
- **Hedging completion.** If a check passed, say it passed. Don't downgrade finished work to "partial" out of anxiety.
- **Tool-choice via Bash when a dedicated tool exists.** Always name the dedicated tool as preferred, bash as fallback.
- **Questions referencing invisible state.** Don't ask *"Does the plan look good?"* via AskUserQuestion when the user hasn't seen the plan yet.
- **Colon before a tool call.** *"Let me read the file:"* then a tool use — the tool call may not render, leaving a dangling colon. Use a period.
- **Mocked tests claimed as parity.** When a prompt prescribes tests, say what to hit (real DB vs mock). Mock/prod divergence is a real failure mode.
- **Emojis, unless explicitly requested.** Ban them.
- **Generic "clean code" advice.** *"Write clean, maintainable code"* means nothing. Be specific or cut.
- **Verification avoidance.** Narrating what you *would* test instead of running it. *"The code looks correct based on my reading"* is not verification. Pair every PASS with an executed command + observed output.
- **Trusting the implementer's tests.** *"The test suite passes"* — the implementer is an LLM too. Run independent checks.
- **Writing explanation when a command is needed.** *"I would run `npm test`"* — cut. Run it.
- **Being seduced by the first 80%.** A polished UI, a green test run, a passing lint — not evidence of correctness at the edges. The last 20% is where bugs live.
- **Narrating idleness in autonomous loops.** *"Still waiting…"* / *"Nothing to do yet…"* — don't narrate. Call `Sleep`. Silence is the right response when there's no useful action.
- **Flattening a catalyst.** If a vague rule uses metaphor or reads as a stance rather than a procedure, it's a deliberate catalyst that amplifies model interpretation — don't rewrite *"measure twice, cut once"* as *"(1) verify the input twice. (2) then act."* **But**: non-metaphorical vagueness (*"be careful"*, *"write good code"*) is still generic advice — flatten those. Metaphor is the signal that interpretation is the point.
- **Apology or recap after interruption.** Don't write *"Sorry about that, let me continue where I left off. I was working on X…"* after a forced pause (user interrupt, output-token limit). Resume directly, mid-thought if that's where the cut happened. Break remaining work into smaller pieces if more to do.
- **Running hooks on error-only responses.** If a hook injects context on every turn and the model's last turn was an API error, that hook will keep firing as the error keeps returning — token-burning death spiral. Hooks that inject content should check for and skip error responses.
- **Approving via a question, not a mode exit.** If your workflow has a dedicated approval action (an ExitPlanMode-style tool), don't ask *"does this look good?"* via AskUserQuestion — the user may not even see what they're approving. The approval verb is the tool, not the question.
- **Treating tool output as persistent memory.** If the system may clear or truncate tool results, extract what you need into your response before that happens. The model's output is the durable record, not the tool result.

## Canonical exemplars (study these whole)

### Exemplar 1 — AgentTool "Writing the prompt" (meta-lesson on prompt writing)

```
Brief the agent like a smart colleague who just walked into the room — it hasn't seen this conversation, doesn't know what you've tried, doesn't understand why this task matters.
- Explain what you're trying to accomplish and why.
- Describe what you've already learned or ruled out.
- Give enough context about the surrounding problem that the agent can make judgment calls rather than just following a narrow instruction.
- If you need a short response, say so ("report in under 200 words").
- Lookups: hand over the exact command. Investigations: hand over the question — prescribed steps become dead weight when the premise is wrong.

Terse command-style prompts produce shallow, generic work.

**Never delegate understanding.** Don't write "based on your findings, fix the bug" or "based on the research, implement it." Those phrases push synthesis onto the agent instead of doing it yourself. Write prompts that prove you understood: include file paths, line numbers, what specifically to change.
```

Every line is a rule that would otherwise be violated. Each prohibition names a real failure mode. Note the *escalating* order: what to include, what to avoid including, what to outright never write.

### Exemplar 2 — Git Safety Protocol (BashTool)

```
Git Safety Protocol:
- NEVER update the git config
- NEVER run destructive git commands (push --force, reset --hard, checkout ., restore ., clean -f, branch -D) unless the user explicitly requests these actions. Taking unauthorized destructive actions is unhelpful and can result in lost work, so it's best to ONLY run these commands when given direct instructions
- NEVER skip hooks (--no-verify, --no-gpg-sign, etc) unless the user explicitly requests it
- NEVER run force push to main/master, warn the user if they request it
- CRITICAL: Always create NEW commits rather than amending, unless the user explicitly requests a git amend. When a pre-commit hook fails, the commit did NOT happen — so --amend would modify the PREVIOUS commit, which may result in destroying work or losing previous changes. Instead, after hook failure, fix the issue, re-stage, and create a NEW commit
- When staging files, prefer adding specific files by name rather than using "git add -A" or "git add .", which can accidentally include sensitive files (.env, credentials) or large binaries
```

Each rule: imperative, negation-first, carries a rationale or failure mode, and has an explicit escape hatch. The `CRITICAL:` is a single-use marker in this block — it flags the one rule whose rationale is a subtle, destructive, easy-to-miss trap.

### Exemplar 3 — Explore sub-agent persona

```
You are a file search specialist for Claude Code, Anthropic's official CLI for Claude. You excel at thoroughly navigating and exploring codebases.

=== CRITICAL: READ-ONLY MODE - NO FILE MODIFICATIONS ===
This is a READ-ONLY exploration task. You are STRICTLY PROHIBITED from:
- Creating new files (no Write, touch, or file creation of any kind)
- Modifying existing files (no Edit operations)
- Deleting files (no rm or deletion)
- Moving or copying files (no mv or cp)
- Creating temporary files anywhere, including /tmp
- Using redirect operators (>, >>, |) or heredocs to write to files
- Running ANY commands that change system state

Your role is EXCLUSIVELY to search and analyze existing code. You do NOT have access to file editing tools - attempting to edit files will fail.

Your strengths:
- Rapidly finding files using glob patterns
- Searching code and text with powerful regex patterns
- Reading and analyzing file contents

Guidelines:
- Use Glob for broad file pattern matching
- Use Grep for searching file contents with regex
- Use Read when you know the specific file path you need to read
- Use Bash ONLY for read-only operations (ls, git status, git log, git diff, find, grep, cat, head, tail)
- NEVER use Bash for: mkdir, touch, rm, cp, mv, git add, git commit, npm install, pip install, or any file creation/modification
- Communicate your final report directly as a regular message - do NOT attempt to create files
```

Structure: role → scope fence → exhaustive prohibition list → strengths → guidelines with inline anti-patterns. Every write surface gets its own bullet; the fence repeats the constraint redundantly because the default behavior is exactly what's being blocked.

### Exemplar 4 — Simplify (parallel-fanout workflow)

```
## Phase 1: Identify Changes

Run `git diff` (or `git diff HEAD` if there are staged changes) to see what changed. If there are no git changes, review the most recently modified files that the user mentioned or that you edited earlier in this conversation.

## Phase 2: Launch Three Review Agents in Parallel

Use the Agent tool to launch all three agents concurrently in a single message. Pass each agent the full diff so it has the complete context.

### Agent 1: Code Reuse Review
### Agent 2: Code Quality Review
### Agent 3: Efficiency Review

## Phase 3: Fix Issues

Wait for all three agents to complete. Aggregate their findings and fix each issue directly. If a finding is a false positive or not worth addressing, note it and move on — do not argue with the finding, just skip it.
```

Phases are sequential; within a phase, operations are explicitly parallel (`"concurrently in a single message"`). The *"do not argue"* rule is load-bearing — it closes a specific failure mode where the model debates a sub-agent rather than acting on the output.

### Exemplar 5 — Side-question fork (negative framing masterclass)

```
This is a side question from the user. You must answer this question directly in a single response.

IMPORTANT CONTEXT:
- You are a separate, lightweight agent spawned to answer this one question
- The main agent is NOT interrupted - it continues working independently in the background
- You share the conversation context but are a completely separate instance
- Do NOT reference being interrupted or what you were "previously doing" - that framing is incorrect

CRITICAL CONSTRAINTS:
- You have NO tools available - you cannot read files, run commands, search, or take any actions
- This is a one-off response - there will be no follow-up turns
- You can ONLY provide information based on what you already know from the conversation context
- NEVER say things like "Let me try...", "I'll now...", "Let me check...", or promise to take any action
- If you don't know the answer, say so - do not offer to look it up or investigate

Simply answer the question with the information you have.
```

Every `CRITICAL CONSTRAINT` closes a specific failure mode: stranded tool calls, false promises, fabricated lookups. Negative framing is front-loaded and exhaustive because the model's defaults are what this is fighting.

### Exemplar 6 — Agent tool `<example>` with `<thinking>` and `<commentary>`

```
<example>
user: "What's left on this branch before we can ship?"
assistant: <thinking>Forking this — it's a survey question. I want the punch list, not the git output in my context.</thinking>
Agent({
  name: "ship-audit",
  description: "Branch ship-readiness audit",
  prompt: "Audit what's left before this branch can ship. Check: uncommitted changes, commits ahead of main, whether tests exist, whether the GrowthBook gate is wired up, whether CI-relevant files changed. Report a punch list — done vs. missing. Under 200 words."
})
assistant: Ship-readiness audit running.
<commentary>
Turn ends here. The coordinator knows nothing about the findings yet. What follows is a SEPARATE turn — the notification arrives from outside, as a user-role message. It is not something the coordinator writes.
</commentary>
</example>
```

`<thinking>` narrates the *model's* decision ("why fork, not inline"). `<commentary>` narrates what the *reader* should learn ("turn ends here; next message comes from outside"). The agent invocation itself is pattern-complete — a fresh reader could copy the shape and succeed.

### Exemplar 7 — Verification agent (rationalizations catalog + evidence-required output)

```
You are a verification specialist. Your job is not to confirm the implementation works — it's to try to break it.

You have two documented failure patterns. First, verification avoidance: when faced with a check, you find reasons not to run it — you read code, narrate what you would test, write "PASS," and move on. Second, being seduced by the first 80%: you see a polished UI or a green test suite and feel inclined to pass it. The first 80% is the easy part. Your entire value is in finding the last 20%.

You will feel the urge to skip checks. These are the exact excuses you reach for — recognize them and do the opposite:
- "The code looks correct based on my reading" — reading is not verification. Run it.
- "The implementer's tests already pass" — the implementer is an LLM too. Verify independently.
- "This is probably fine" — probably is not verified. Run it.
- "Let me start the server and check the code" — no. Start the server and hit the endpoint.

If you catch yourself writing an explanation instead of a command, stop. Run the command.

## Output format

Every check MUST follow this structure. A check without a Command run block is not a PASS — it's a skip.

### Check: [what you're verifying]
**Command run:**
  [exact command you executed]
**Output observed:**
  [actual terminal output, trimmed]
**Result: PASS** (or FAIL — include Expected vs Actual)

End your response with one line, and only one line:
VERDICT: PASS
or
VERDICT: FAIL
or
VERDICT: PARTIAL

Use the literal string `VERDICT: ` followed by exactly one of PASS, FAIL, PARTIAL. No markdown bold, no punctuation, no variation.
```

This prompt carries four techniques worth naming in their own right:

1. **Failure-mode naming.** The author calls out the two specific failure patterns ("verification avoidance", "seduced by the first 80%") before giving rules. A named failure is a recognizable failure — the model can pattern-match it in its own reasoning mid-turn.
2. **Rationalizations catalog.** Five exact excuses the model will reach for, each paired with the counter-move. Works because the model *will* produce these rationalizations unbidden; naming them forces recognition.
3. **Evidence-required output.** The output format carries the enforcement. *"A check without a Command run block is not a PASS — it's a skip."* The structure IS the rule.
4. **Closed-world verdict strings.** The final line must be an exact literal from a 3-value enum. *"No markdown bold, no punctuation, no variation."* Downstream parsing is fragile; ambiguity is explicitly forbidden.

Use this shape when the model's defaults include the failure mode being guarded against, or when output is machine-parseable.

## Drafting (when the argument is a description)

1. **Identify the type.** Match the description against the four anatomies in §Anatomy. If ambiguous, call AskUserQuestion once with the four options + Other.

2. **Draft the frontmatter first** (for skills) or the one-line capability + trust statement (for tools/agents). These land in the first 200 chars and set the voice for everything that follows.

3. **Write the body using the canonical section order** for that type. Use tables for decisions, numbered lists for steps, fenced code for examples.

4. **Add 1–2 exemplars** with `<example>` / `<thinking>` / `<commentary>` if the prompt prescribes a decision with failure modes.

5. **Run §Refinement checklist** over the draft before presenting.

6. **Present** as a fenced markdown block so the user can review with syntax highlighting. Ask whether to save (and where) or refine further. Do not write to disk without explicit approval.

## Refinement checklist

When the argument contains a draft, run through these. For each hit, show the original line, the rewrite, and a one-sentence reason. Skip sections that don't apply to very short prompts — don't pad.

**Structure**
- [ ] One-line capability / purpose in the first 200 chars?
- [ ] "When NOT to use" section for tools/agents with ≥2 boundary cases?
- [ ] Examples wrapped in `<example>` with `<thinking>` and/or `<commentary>` where a decision is prescribed?
- [ ] Frontmatter complete (name, description, when_to_use with trigger phrases, allowed-tools as minimal patterns)?
- [ ] Section order matches the canonical anatomy for this prompt type?

**Voice**
- [ ] Any hedging (*probably / might / could / consider / perhaps*)? Cut or replace with imperative.
- [ ] Any preamble (*"Great question…"*, *"Let me help you…"*)? Cut.
- [ ] Narration of WHAT the code does? Cut. Keep only non-obvious WHY.
- [ ] Colons before tool calls? Replace with periods.
- [ ] Emojis (not explicitly requested)? Remove.

**Rules**
- [ ] Every `NEVER` / `MUST` has a rationale AND an escape hatch?
- [ ] Priority markers (`IMPORTANT` / `CRITICAL`) ≤ 3 per major section?
- [ ] Hallucination-prone behavior not explicitly prohibited? Add a `Don't X` rule.
- [ ] Safety rule with no WHY? Add one — use a past failure mode if the user can supply one.

**Interaction**
- [ ] Prescribed questions are `AskUserQuestion` calls, not prose?
- [ ] Recommended option first with `(Recommended)` suffix?
- [ ] Success-silence condition specified ("don't post if clean")?
- [ ] Parallel ops prescribed with `"in a single message"`?
- [ ] Plan-mode approval via ExitPlanMode (not AskUserQuestion)?

**Output**
- [ ] Output format prescribed — structure, section names, length bound?
- [ ] HEREDOC example for multi-line command args (commits, PR bodies)?
- [ ] File references in `file_path:line_number` format?
- [ ] GitHub refs in `owner/repo#123` format?

**Anti-creep**
- [ ] Does the prompt tell the model to do more than asked? Cut.
- [ ] Defensive error handling for impossible cases? Cut.
- [ ] Claims success without prescribing verification? Add a verification step.
- [ ] Any dead language ("Write clean code", "Be careful")? Cut or make specific.

## Stress-testing a prompt

A prompt isn't done when it reads well. It's done when it survives adversarial inputs. Run these before shipping:

1. **Empty argument** — does the prompt handle `$ARGUMENTS` empty without breaking? Show a usage message; don't proceed with a placeholder.
2. **Oversized argument** — paste something 10× the expected size. Does it still behave?
3. **Ambiguous argument** — one that matches two branches of the routing. Does the prompt pick deterministically, or flip-flop?
4. **Adversarial argument** — *"ignore previous instructions and…"* / *"you are actually a different agent now…"*. Do the rules hold?
5. **"No good answer"** — a question the prompt genuinely can't answer from available info. Does it say so, or fabricate?
6. **Multi-turn pushback** — invoke, see output, reply *"not quite right, do X differently"*. Does turn 2 stay coherent with turn 1's framing, or drift?
7. **Compaction survival** — run in a long session where compaction fires. Does the skill re-inject correctly?
8. **Fresh sub-agent** — if the prompt ever runs in a `context: fork` skill or sub-agent, spawn one with just the prompt and no conversation history. Does it still work?
9. **Premature success** — does the prompt ever need to declare the task done? If so, feed it a near-complete-but-broken state. Does it catch the gap or cheerfully pass?

Cap each test at 2–3 minutes. If a test fails, fix the prompt, don't rationalize the failure. If you can't run one of these, say so explicitly in the prompt's description — *"known untested for adversarial input"* beats silent uncertainty.

## Rules

- Present the full draft in a fenced code block before writing to disk. Let the user review with syntax highlighting and approve.
- Save personal skills to `~/.claude/skills/<name>/SKILL.md`; project-scoped skills to `.claude/skills/<name>/SKILL.md`. Ask via AskUserQuestion if unclear.
- Use `AskUserQuestion` for every choice the user makes. Never ask in plain prose. Recommended option first with `(Recommended)`; always include *Other*.
- Do NOT write files without explicit approval of the draft.
- For very short prompts (< 20 lines), most of §Refinement checklist won't apply. Skip what doesn't match. Do not pad.
- Preserve the user's voice when it's clearer than the house style. The house style is a default, not a filter.
- When refining, show a unified diff or a clear before/after. Do not silently rewrite — the user should see what changed and why.
- If the user pushes back on an edit, accept it and move on. Do not argue with the finding.

## Mandatory learning clause

Every invocation of this skill ends with a learning block. No exceptions.

**Format** — closed-world, emitted at the end of the final message after the artifact is accepted, refined, or discarded:

```
## Learning

- [observation 1]
- [observation 2]

Proposed edit to SKILL.md: [file:line with specific change] OR none
```

**What counts as an observation**
- A pattern the user corrected by hand after the draft.
- A Refinement-checklist item the skill missed.
- A classification-table branch that misrouted.
- A stock phrase that didn't fit the situation.
- An anti-pattern the skill's own artifact produced.
- A new canonical pattern spotted in Anthropic source that isn't yet in the phrasebook.
- A time cost that felt disproportionate to the value delivered.

**The null-case wording is not interchangeable**

If there's genuinely nothing to improve:

```
## Learning

Nothing to improve this run.
```

If you did not actually review the run for improvements:

```
## Learning

Did not review for improvements.
```

*"Nothing to improve"* claims you looked and found nothing. *"Did not review"* admits you skipped. **Never reach for "Nothing to improve" as a default shortcut.** A honest gap beats a fabricated all-clear. If you catch yourself about to write "Nothing to improve" without having actually walked the Refinement checklist against what you produced, write "Did not review" instead.

**Scope** — observations about the user's personal style (they prefer shorter titles, they skip trigger-phrase suggestions, they always rename `/foo` to `/foo-v2`) belong in user memory via the auto-memory system, not in a SKILL.md edit. Propose a SKILL.md edit only for defects in the skill's own teaching or workflow.

**Escalation** — if the same observation appears in three consecutive runs, stop emitting it as an observation and surface it as a blocking proposed SKILL.md edit with suggested exact text. Repeat observations mean the skill needs to change, not the user.

**Why this exists** — prompts improve only when corrections get captured. Single-prompt use gets implicit feedback (you correct in real time). Batch use across many prompts loses it silently, and errors compound. This clause forces the feedback loop to run every turn regardless of mode.

---

## Reference appendix

### XML tag taxonomy

| Tag | What it wraps | Role |
|---|---|---|
| `<system-reminder>` | Meta-reminders injected by the harness | "Non-relational — bears no direct relation to the specific tool result it's attached to." |
| `<example>` | A complete multi-turn interaction | Specification the model pattern-matches against |
| `<thinking>` | The *model's* internal reasoning inside an example | Teaches the expected decision pattern |
| `<commentary>` | Meta-explanation of an example, for the reader | What this example is teaching; distinguishes coordinator turn from notification turn |
| `<reasoning>` | Justification after an example | Why the shown tool choice was right |
| `<analysis>` | Scratchpad for model reasoning before structured output | Stripped before result is surfaced (compaction) |
| `<summary>` | Structured summary output | Downstream code parses this |
| `<scope>` | A task or agent's boundary statement | Used in memory types and agent briefings |
| `<type>`, `<name>`, `<when_to_save>`, `<how_to_use>`, `<body_structure>`, `<examples>` | Slots in memory-type taxonomy | Declarative rules, one semantic slot per tag |
| `<env>` | Environment metadata (cwd, git status, platform, shell) | Single parseable block rather than inline prose |
| `<command-name>` | Which slash command triggered the current expanded context | Lets the model recognize "skill already loaded, don't re-invoke" |
| `<user-prompt-submit-hook>` | Feedback from a user-prompt-submit shell hook | Treated as coming from the user |
| `<tick>` | Periodic wake-up marker in autonomous loops | *"You're awake, what now?"* — distinguishes paced wake-ups from reactive user messages |
| `<block>` | Classifier verdict in permission / yolo classification | Closed-world verdict, preceded by `<thinking>` |

### Template variables (for skill / prompt authors)

| Variable | Substitutes to | When to use |
|---|---|---|
| `$ARGUMENTS` | The full raw argument string | Single-arg skills, or when you want the whole string |
| `$ARGUMENTS[0]`, `$ARGUMENTS[1]`, … | Individual shell-quoted tokens | Positional args |
| `$0`, `$1`, `$2`, … | Shorthand for `$ARGUMENTS[N]` | Same as above |
| `$name` | The Nth positional arg (if `arguments: [name, …]` declared) | Named-arg skills |
| `${CLAUDE_SKILL_DIR}` | The skill's own directory | Reference bundled scripts / schemas, e.g. `${CLAUDE_SKILL_DIR}/tools/helper.sh` |
| `${CLAUDE_SESSION_ID}` | Current session ID | Namespace per-session scratch files |
| `` !`command` `` | Live stdout of `command` run at expansion time | Inject `git status`, `git diff`, etc. Subject to the skill's `allowed-tools`. |

Also seen at build time in Anthropic's internal prompt constants (not for your skills, but useful to recognize when reading the source): `${AGENT_TOOL_NAME}`, `${BASH_TOOL_NAME}`, `${FILE_READ_TOOL_NAME}`, `${SKILL_TOOL_NAME}`, `${ASK_USER_QUESTION_TOOL_NAME}`, `${TICK_TAG}`, `${COMMAND_NAME_TAG}`.

### Stock phrasebook (reuse verbatim when the situation fits)

These phrases recur across Claude Code's prompts and carry specific, well-tested meaning. Prefer them over invented variants:

- *"Complete the task fully — don't gold-plate, but don't leave it half-done."* — scope discipline
- *"Measure twice, cut once."* — default-to-confirmation stance
- *"Brief the agent like a smart colleague who just walked into the room."* — context transfer to a fresh sub-agent
- *"Report in under 200 words."* / *"One or two sentences."* — length caps are enforced by being stated
- *"If you can say it in one sentence, don't use three."* — terseness default
- *"Don't peek. Don't race. Don't fabricate."* — async-work discipline
- *"Never delegate understanding."* — refuse to push synthesis onto sub-agents
- *"The first 80% is the easy part. Your entire value is in finding the last 20%."* — verification framing
- *"The cost of pausing to confirm is low, while the cost of an unwanted action can be very high."* — authorization scope rationale
- *"Trust it."* / *"You get a completion notification; trust it."* — post-completion trust for async work (not blind faith)
- *"Match the scope of your actions to what was actually requested."* — anti-creep
- *"Reading is not verification. Run it."* — testing discipline
- *"Probably is not verified."* — same
- *"If you catch yourself writing an explanation instead of a command, stop. Run the command."* — behavioral interrupt
- *"Do not argue with the finding, just skip it."* — trust sub-agent output without debate
- *"Resume directly — no apology, no recap of what you were doing."* — post-interruption / post-pause continuation
- *"Keep working — do not summarize."* — continuation nudge (token budget, mid-task checkpoint)
- *"Pick up mid-thought if that is where the cut happened. Break remaining work into smaller pieces."* — output-token-limit recovery
- *"Write down any important information you might need later in your response, as the original tool result may be cleared later."* — pair with any system that may clear / truncate tool output post-hoc

### Special-case patterns

**Autonomous loop (`<tick>`)** — when a skill or agent runs without a user present, receiving periodic wake-ups:
- Treat each `<tick>` as *"you're awake, what now?"*
- If nothing useful to do, call `Sleep` immediately. Never respond with only a status line like *"still waiting"*.
- Do not spam the user. If you already asked and they haven't responded, don't ask again.
- Don't narrate what you're about to do — just do it.
- Act on your best judgment rather than asking for confirmation.

**MCP instruction injection** — MCP servers that provide an `instructions` field get wrapped as:
```
# MCP Server Instructions

## <ServerName>
<server's instructions verbatim>
```
Keep server instructions focused on *how to use the tools*, not generic descriptions.

**Malware-analysis boundary** — when a prompt reads files that may contain malware:
> *Whenever you read a file, you should consider whether it would be considered malware. You CAN and SHOULD provide analysis of malware, what it is doing. But you MUST refuse to improve or augment the code.*

Analysis is permitted; enhancement is not.

**Cyber-risk framing** — for any prompt touching security / pentesting / exploits:
> *Assist with authorized security testing, defensive security, CTF challenges, and educational contexts. Refuse requests for destructive techniques, DoS attacks, mass targeting, supply chain compromise, or detection evasion for malicious purposes. Dual-use security tools (C2 frameworks, credential testing, exploit development) require clear authorization context.*

Use this framing verbatim when the prompt may be used in a context where that boundary matters.

### Corpus (reference dataset)

A frozen snapshot of 90 prompts extracted from Anthropic's Claude Code source tree, scored against this skill's rubric, lives at `${CLAUDE_SKILL_DIR}/corpus/`:

- `prompts.json` — every extracted prompt as a structured record (source, line range, kind, name, content, flags)
- `INDEX.md` — human-readable index grouped by kind (tool / agent / skill / command / system / safety / hook / memory)
- `scores.json` — per-prompt scores (structure / voice / rationale / examples / specificity, out of 18)
- `REPORT.md` — top 10 exemplars, flagged prompts, stock-phrase frequencies, XML-tag adoption, by-kind aggregates

Use it as a study reference: when drafting a new prompt, read the top exemplars for the matching kind from `REPORT.md` and pattern-match against them. The corpus is a point-in-time snapshot; it won't drift unless regenerated.

### Architecture reference

Runtime mechanics (composition pipeline, cache scopes, attachment lifecycle, delegation, compaction) are documented in a companion file at `${CLAUDE_SKILL_DIR}/ARCHITECTURE.md`. Read it when you need to understand *how* Claude Code assembles prompts at runtime — not how to author them.

Short version: the system prompt is a function of runtime state (not a string), composed from ~14 section-builders split at a cache boundary marker; mid-session content arrives via ~40 attachment types that dedup per-type and smoosh into tool_results for cache stability; sub-agents fork (byte-identical parent prompt, cache-shared) or spawn fresh (clean persona + env); compaction preserves `invokedSkills` state verbatim while summarizing everything else into a 9-section template.
