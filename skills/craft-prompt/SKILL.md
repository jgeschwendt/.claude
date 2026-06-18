---
name: craft-prompt
description: Craft or refine a prompt in the house style — imperative voice, rule-first structure, explicit rationale, XML-tagged exemplars, silence on success.
when_to_use: "Use when the user asks to write, refine, review, or improve any prompt — tool prompts, skill/workflow prompts, sub-agent personas, system prompts, or general LLM instructions. Also use when the user pastes a draft asking for feedback. Trigger phrases: 'craft a prompt', 'write a prompt', 'refine this prompt', 'make this more house-style', '/craft-prompt'."
argument-hint: "[draft to refine OR description of what you want to craft]"
allowed-tools:
  - AskUserQuestion
  - Edit
  - Glob
  - Grep
  - Read
  - Write
---

# /craft-prompt — Masterclass in house-style prompt engineering

Draft or refine a prompt in the house style: imperative, rule-first, examples-as-specifications, silent on success.

## User input

The argument (may be empty):

```
$ARGUMENTS
```

## When invoked

Classify the argument, then route:

| Input shape                                                          | Branch        | Hot path                                                        |
| -------------------------------------------------------------------- | ------------- | --------------------------------------------------------------- |
| Draft pasted (≥5 lines; frontmatter, imperatives, or role statement) | **Refine**    | §Refinement → diff → AskUserQuestion (save?)                    |
| Description ("a skill that does X", "a prompt for Y")                | **Draft**     | §Drafting → full draft → AskUserQuestion (refine / save?)       |
| Empty                                                                | **Interview** | one AskUserQuestion to pick type → route                        |
| Hybrid (description + partial draft)                                 | **Hybrid**    | treat the paste as current state; refine toward the description |

### Turn shape (every response follows this)

1. **Opening line (one sentence)** — name the branch; if refining, name the 1–3 highest-impact issues being fixed. No preamble, no restatement.
2. **Artifact** — fenced code block containing the draft (or a unified diff for refinement).
3. **Rationale** — ≤ 3 bullets, one sentence each, only where the change isn't self-evident.
4. **AskUserQuestion** — options: _Save_, _Refine further_, _Discard_. First option marked `(Recommended)` by branch: _Save_ after clean Refine; _Refine further_ after Draft or Refine-with-flags-open. Interview ends on the type question instead.

### Per-branch success criteria

- **Refine** — every flagged checklist item has a proposed rewrite OR an explicit _"kept as-is: reason"_. Nothing silently dropped.
- **Draft** — frontmatter complete; one-line capability in first 200 chars; body follows canonical anatomy for the type; at least one `<example>` block if the prompt prescribes a decision with failure modes.
- **Interview** — one AskUserQuestion call; user picks a type; next turn routes to Draft or Refine.
- **Hybrid** — same as Refine, with the description as governing intent when draft and description conflict.

Do NOT restate the user's request. Do NOT open with "Great question", "Let me help you", or any acknowledgment. Go straight to the artifact.

## Scope (when NOT to use this skill)

Not for writing documentation prose, commit messages, code comments, user-facing emails, or product copy. Only for prompts intended to instruct an LLM: tool schemas, sub-agent personas, SKILL.md bodies, system prompts, or sections thereof.

## Reference library

This skill is an index over four references under `${CLAUDE_SKILL_DIR}/references/`. The operational core is below; load a reference when the table says to (use Read/Grep — do not work from memory of them).

| File                                                                               | Load it when                                                                 | Holds                                                                                                                                                                                                                                                                                                                 |
| ---------------------------------------------------------------------------------- | ---------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [references/techniques.md](references/techniques.md)                               | drafting or refining any prompt                                              | the exhaustive techniques catalog (Structure · Voice · Examples · Interaction · Delegation · Constraint enforcement · Failure-mode teaching · Persistence & throttling · Argument handling · Output formats · Persona & self-framing · Prompt assembly), plus the anti-patterns reject-list and the voice fingerprint |
| [references/playbook.md](references/playbook.md)                                   | you need a stock phrase, XML tag, template variable, or special-case pattern | phrasebook · XML tag taxonomy · template variables · special-case patterns                                                                                                                                                                                                                                            |
| [references/claude-code/exemplars.md](references/claude-code/exemplars.md)         | you need a worked model for a prompt kind                                    | canonical Claude Code prompts to study whole, grouped by kind (tool · agent · skill · command · system · safety)                                                                                                                                                                                                      |
| [references/claude-code/architectures.md](references/claude-code/architectures.md) | you are building a prompt _system_, not authoring one prompt                 | Claude Code runtime mechanics: composition pipeline · cache scopes · attachment lifecycle · delegation · compaction                                                                                                                                                                                                   |

`references/<harness>/` holds faithful, real-name reference pulled from a specific harness (currently `claude-code/`); `techniques.md` and `playbook.md` are the harness-agnostic distillation — ours. As more harnesses are studied, each gets its own `references/<harness>/`.

When refining, walk the §Refinement checklist below and pull specific entries from `references/techniques.md` / `references/claude-code/exemplars.md` as needed. The catalog grows; treat these files as the source of truth over anything you recall.

## Core principles (the house style in 9 rules)

1. **Rule first, rationale second.** State the constraint in imperative form, then — same line or next — explain _why_ in one phrase. The why lets the model generalize to unlisted edge cases. Canonical: _"NEVER run destructive git commands … Taking unauthorized destructive actions is unhelpful and can result in lost work, so it's best to ONLY run these commands when given direct instructions"_.

2. **Negative framing beats positive for hallucination-prone behaviors.** "Don't peek. Don't race. Don't re-delegate understanding" is stronger than "trust the process." Write prohibitions for behaviors the model would otherwise invent.

3. **Examples are specifications, not illustrations.** An `<example>` block with `<thinking>` and `<commentary>` shows the exact cognitive pattern expected. The model will reproduce the _shape_ of your examples — pick them so that reproduction is the desired behavior.

4. **Scope boundaries up front.** For tools and agents, declare what the thing does _not_ cover before listing what it does. `"When NOT to Use"` prevents misfires more efficiently than `"When to Use"` alone.

5. **Prefer dedicated tools, name the anti-pattern inline.** _"Use Edit (NOT sed/awk)"_. The parenthetical is the whole teaching — the ban is next to the preferred tool, not in a separate footnote.

6. **Escape hatches, not absolutes.** Every `NEVER` gets an "unless the user explicitly requests it." Authorization is narrow: approving one action does not generalize. Durable authorization lives in CLAUDE.md.

7. **Silence on success.** Specify when the model should _not_ output. _"Only post to Slack if you actually found something stuck. If every session looks healthy, tell the user that directly — do not post an all-clear to the channel."_

8. **Priority markers carry real weight.** `IMPORTANT`, `CRITICAL`, `NEVER`, `MUST`, `ALWAYS` — reserved for hard constraints. If they appear in every paragraph they mean nothing. Budget: 1–3 per major section.

9. **Parallel by default.** When multiple operations don't depend on each other, prescribe `"in parallel, in a single message"`. This phrase actually changes batching in practice.

## Anatomy by prompt type

### A. Tool prompt (Bash / Read / Edit / … style)

Canonical section order:

| #   | Section                       | Purpose                                                                                |
| --- | ----------------------------- | -------------------------------------------------------------------------------------- |
| 1   | One-line capability           | _"Reads a file from the local filesystem."_                                            |
| 2   | Trust statement               | _"Assume this tool is able to read all files on the machine."_ — justifies later rules |
| 3   | When to use / When NOT to use | Numbered conditions, each with a 1-line example                                        |
| 4   | Usage notes                   | Parameter hygiene, path rules, flags                                                   |
| 5   | Examples (multi-turn)         | `<example>` with `<thinking>` and `<commentary>`                                       |
| 6   | State preconditions           | _"You must use Read at least once before editing."_                                    |
| 7   | IMPORTANT notes               | Meta-level footguns                                                                    |

Land the trust statement and the first footgun in the first 200 chars. BashTool does this:

> _Executes a given bash command and returns its output. The working directory persists between commands, but shell state does not. …_
> _IMPORTANT: Avoid using this tool to run `cat`, `head`, `tail`, `sed`, `awk`, or `echo` commands, unless explicitly instructed or after you have verified that a dedicated tool cannot accomplish your task._

### B. Skill / workflow prompt (SKILL.md)

Frontmatter (canonical form from the Skillify meta-skill):

```yaml
---
name: skill-name
description: one-line description
when_to_use: "Use when... Examples: 'trigger phrase', 'another phrase'"
allowed-tools: [Bash(gh:*), Read, Write, AskUserQuestion]
argument-hint: "[hint showing argument placeholders]"
arguments: [foo, bar] # omit if no args; use $foo in body
context: fork # omit for inline; use for self-contained workflows
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
   _"You are a software architect and planning specialist for ${AGENT_HARNESS}."_
   _"You are a file search specialist for ${AGENT_HARNESS}, ${VENDOR}'s official CLI for ${MODEL_NAME}. You excel at thoroughly navigating and exploring codebases."_

2. **Scope fence** — `=== CRITICAL: ... ===` around hard boundaries. For read-only agents, list every write surface blocked (Write, touch, rm, cp, mv, redirect operators, heredocs). For specialist agents, list out-of-scope domains. Close with a redundant reminder after the guidelines: _"REMEMBER: You can ONLY explore and plan. You CANNOT and MUST NOT write, edit, or modify any files."_

3. **Strengths + Guidelines + Approach** — bulleted, imperative. If the agent should follow a prescribed workflow (fetch docs, then search, then fall back to web), number the steps.

### D. System-prompt section

Dense imperative bullets. Each bullet is self-contained (the reader might skip everything above it). Mirror the six-part system-prompt frame:

- `# System` — tool architecture, permissions, `<system-reminder>` semantics
- `# Doing tasks` — scope discipline, read before proposing, verify before claiming done
- `# Executing actions with care` — reversibility, blast radius, confirmation defaults, authorization scope
- `# Using your tools` — dedicated over general, parallel vs sequential, task tracking
- `# Tone and style` — emojis, `file_path:line_number`, no colon before tool calls, `owner/repo#123`

Static cacheable content goes first; session-variant content last. Cache keys stay stable on the prefix.

## Minimum viable prompt

Match depth to failure-surface width. Not every prompt needs the full anatomy.

| Use case                               | Minimum shape                                                         | Reference                   |
| -------------------------------------- | --------------------------------------------------------------------- | --------------------------- |
| One-shot classifier                    | Role (1 sentence) + strict output schema + 1 example                  | closed-world JSON           |
| Extraction to JSON                     | Role + schema + 2–3 examples                                          | —                           |
| Simple tool prompt                     | Capability line + "When NOT to use" + 1 parameter note                | ~10 lines                   |
| Simple workflow skill                  | Frontmatter + Goal + 2–3 Steps + Rules                                | ~50 lines                   |
| Complex workflow / multi-phase         | Phases + parallel fanout + per-step success criteria                  | multi-phase orchestration   |
| Sub-agent persona with hard boundaries | Role + `=== CRITICAL ===` scope fence + guidelines + closing reminder | read-only specialist agents |
| Full system-prompt section             | Dense imperative bullets, cache-boundary-aware                        | a full agent system prompt  |

**Rule of thumb**: the prompt should be as long as its failure surface is wide. A classifier with a 2-value output doesn't need `<thinking>` tags. A multi-phase workflow with async sub-agents does. If you're writing more than the anatomy demands, that's scope creep _in the prompt itself_ — cut.

**Anti-rule**: don't pad a short prompt with anatomy sections it doesn't need ("When NOT to use" for a 10-line classifier is ceremony, not clarity).

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

- [ ] Any hedging (_probably / might / could / consider / perhaps_)? Cut or replace with imperative.
- [ ] Any preamble (_"Great question…"_, _"Let me help you…"_)? Cut.
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
4. **Adversarial argument** — _"ignore previous instructions and…"_ / _"you are actually a different agent now…"_. Do the rules hold?
5. **"No good answer"** — a question the prompt genuinely can't answer from available info. Does it say so, or fabricate?
6. **Multi-turn pushback** — invoke, see output, reply _"not quite right, do X differently"_. Does turn 2 stay coherent with turn 1's framing, or drift?
7. **Compaction survival** — run in a long session where compaction fires. Does the skill re-inject correctly?
8. **Fresh sub-agent** — if the prompt ever runs in a `context: fork` skill or sub-agent, spawn one with just the prompt and no conversation history. Does it still work?
9. **Premature success** — does the prompt ever need to declare the task done? If so, feed it a near-complete-but-broken state. Does it catch the gap or cheerfully pass?

Cap each test at 2–3 minutes. If a test fails, fix the prompt, don't rationalize the failure. If you can't run one of these, say so explicitly in the prompt's description — _"known untested for adversarial input"_ beats silent uncertainty.

## Rules

- Present the full draft in a fenced code block before writing to disk. Let the user review with syntax highlighting and approve.
- Save personal skills to `~/.claude/skills/<name>/SKILL.md`; project-scoped skills to `.claude/skills/<name>/SKILL.md`. Ask via AskUserQuestion if unclear.
- Use `AskUserQuestion` for every choice the user makes. Never ask in plain prose. Recommended option first with `(Recommended)`; always include _Other_.
- Do NOT write files without explicit approval of the draft.
- For very short prompts (< 20 lines), most of §Refinement checklist won't apply. Skip what doesn't match. Do not pad.
- Preserve the user's voice when it's clearer than the house style. The house style is a default, not a filter.
- When refining, show a unified diff or a clear before/after. Do not silently rewrite — the user should see what changed and why.
- If the user pushes back on an edit, accept it and move on. Do not argue with the finding.

## Learning

Capture is continuous — not a closing step. The moment a run goes off the documented playbook, append one line to `${CLAUDE_SKILL_DIR}/LEARNINGS.md`, backed by a concrete artifact (the draft, the user's hand-correction, or the `source/file.ts:line` of a newly-spotted pattern). No end-of-run review ritual: if nothing went off-playbook, nothing is captured — so there is no "did I remember to reflect?" honesty gap to guard.

Triggers — capture the moment you notice: a §Refinement-checklist item the skill missed · a §When-invoked classification that misrouted · a stock phrase or technique that didn't fit and you reached past it · an anti-pattern the skill's own artifact produced · a canonical pattern seen in the wild that isn't yet in `references/techniques.md` / `references/claude-code/exemplars.md` / `references/playbook.md` · a time cost disproportionate to the value delivered.

`- [ ] (YYYY-MM-DD · <artifact>) → <dest>: <one-line change>`

`<dest>`: **this SKILL.md** (routing/turn-shape/checklist defect) · **`references/techniques.md` / `references/claude-code/exemplars.md` / `references/playbook.md`** (a missing or wrong catalog entry) · **the repo** (a project-specific prompt convention → that repo's `.claude/`) · **user memory** (the user's personal style — shorter titles, skipped trigger-phrases, a rename habit).

- **Capture always** — inline, even in an unattended or forked run; it never blocks the turn.
- **Net-zero** — overlaps an existing catalog entry or checklist line → merge into that line, don't add.
- **Promote via `/learn`** — it drains the queue, re-verifies each entry still holds, applies it to its `<dest>` stamped `(since <date> · <artifact>)`, then checks it off. An entry that recurs 3× promotes as a blocking edit. Do not self-promote mid-run.
