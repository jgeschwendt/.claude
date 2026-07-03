> Referenced from SKILL.md. Lookup material: stock phrasebook, XML tag taxonomy, template variables, and special-case patterns.

## Reference — stock phrasebook

These phrases are idiomatic in production agent prompts and carry specific, well-tested meaning — though several are rarer than their fame suggests. Prefer them over invented variants:

- _"Complete the task fully — don't gold-plate, but don't leave it half-done."_ — scope discipline
- _"Measure twice, cut once."_ — default-to-confirmation stance
- _"Brief the agent like a smart colleague who just walked into the room."_ — context transfer to a fresh sub-agent
- _"Report in under 200 words."_ / _"One or two sentences."_ — length caps are enforced by being stated
- _"If you can say it in one sentence, don't use three."_ — terseness default
- _"Don't peek. Don't race. Don't fabricate."_ — async-work discipline
- _"Never delegate understanding."_ — refuse to push synthesis onto sub-agents
- _"The first 80% is the easy part. Your entire value is in finding the last 20%."_ — verification framing
- _"The cost of pausing to confirm is low, while the cost of an unwanted action can be very high."_ — authorization scope rationale
- _"Trust it."_ / _"You get a completion notification; trust it."_ — post-completion trust for async work (not blind faith)
- _"Match the scope of your actions to what was actually requested."_ — anti-creep
- _"Reading is not verification. Run it."_ — testing discipline
- _"Probably is not verified."_ — same
- _"If you catch yourself writing an explanation instead of a command, stop. Run the command."_ — behavioral interrupt
- _"Do not argue with the finding, just skip it."_ — trust sub-agent output without debate
- _"Resume directly — no apology, no recap of what you were doing."_ — post-interruption / post-pause continuation
- _"Keep working — do not summarize."_ — continuation nudge (token budget, mid-task checkpoint)
- _"Pick up mid-thought if that is where the cut happened. Break remaining work into smaller pieces."_ — output-token-limit recovery
- _"Write down any important information you might need later in your response, as the original tool result may be cleared later."_ — pair with any system that may clear / truncate tool output post-hoc

**Emphasis vocabulary** — the scarce all-caps markers and what each signals:

- **Mark the single most error-prone instruction.** Prefix the one bullet most likely to be missed with `IMPORTANT:` to raise it above the surrounding stream. _"IMPORTANT: Do not reference \"the plan\" in your questions"_.
- **Pair IMPORTANT with an absolute for forgotten habits.** When the model habitually drops a behavior, stack the marker with Always/Never. _"IMPORTANT: Always mark your assigned tasks as resolved when you finish them"_.
- **Give the one mandatory output its own header.** Separate the single non-negotiable requirement from soft usage notes with an all-caps header and a direct imperative. _"CRITICAL REQUIREMENT - You MUST follow this:"_.
- **All-caps only the words that flip legality or sequence.** Reserve caps for the few words that change an action's legality or ordering, so emphasis stays scarce. _"It will NOT touch"_, _"ONLY mark a task as completed when you have FULLY accomplished it"_.
- **Capitalize the pivot when a sentence reverses a rule.** When a clause carves an exception out of the rule it just stated, caps the contrast connective so the carve-out is unmissable. _"DO still select memories containing warnings, gotchas, or known issues about those tools — active use is exactly when those matter."_.

**Eagerness and routing** — push past the model's defaults, then route by symptom:

- **Counter tool reticence with "proactively."** The model under-invokes tools unless told; the word flips its default. _"Use this tool proactively in these scenarios:"_.
- **Open a tool family with one shared stem.** Use an identical `Use this tool to …` opening across a family so each tool's purpose parses from a consistent slot. _"Use this tool to list all tasks in the task list."_.
- **Signal the operative rule with a bare "So:".** Open the consequence sentence with `So:` to mark that the preceding rationale now resolves into the rule to follow. _"So: every time the user says something, the reply they actually read comes through ${BRIEF_TOOL_NAME}."_.
- **Pack a decision table into one sentence.** Introduce value definitions with a verb-plus-colon stem and separate cases with semicolons. _"`status` labels intent: 'normal' when replying to what they just asked; 'proactive' when you're initiating"_.
- **Route feedback by symptom class, with an over-trigger guard.** Give a decision rule that maps symptom to channel and fences off the false-positive case. _"recommend the appropriate slash command: /issue for model-related problems (odd outputs, wrong tool choices, hallucinations, refusals), or /share to upload the full session transcript for product bugs... Only recommend these when the user is describing a problem with ${AGENT_HARNESS}."_.
- **Default toward asking, not guessing.** Close a decision table with a blanket fallback so uncovered cases resolve to a question. _"When unsure, ask rather than guess"_.
- **Ban proactive firing for stateful tools.** For a tool whose invocation mutates or tears down session state, state the anti-proactive ban outright — the deliberate inverse of the "use this proactively" push you give discovery tools. _"Do NOT call this proactively — only when the user asks"_.

**Grounding and output shape** — pin the model to supplied content and to a parseable shape:

- **Pin a sub-prompt to the provided text.** For content extraction, suppress pretraining-led recall with an only-the-content clause; repeat the length anchor in every branch. _"Provide a concise response based only on the content above."_ and _"Provide a concise response based on the content above."_.
- **Flatly prohibit high-risk content.** For a high-risk category use a no-escape-hatch absolute, not a softened guideline. _"Never produce or reproduce exact song lyrics."_.
- **Express a denylist as a positive exception.** When most capability is permitted, `All tools except X, Y, Z` is shorter and clearer than enumerating the allowed set. _"All tools except ${disallowedTools.join(', ')}"_.
- **Quantify behavior with units, ranges, and parenthetical caps.** Give the model numbers to reason with, not adjectives. _"recurring tasks fire up to 10% of their period late (max 15 min); one-shot tasks landing on :00 or :30 fire up to 90 s early"_.
- **Demand a machine-parseable category slug.** Require lowercase snake_case with examples so findings group cleanly. <!-- specimen truncated in transcription; re-pull from security-review source -->
- **Mandate a navigable citation format.** State the format and the user benefit it serves. _"When referencing specific functions or pieces of code include the pattern file_path:line_number to allow the user to easily navigate to the source code location."_ and _"When referencing GitHub issues or pull requests, use the owner/repo#123 format (e.g. anthropics/claude-code#100) so they render as clickable links."_.
- **Fix a rendering artifact by naming it.** Explain the artifact and the corrected phrasing rather than just forbidding it. _"Do not use a colon before tool calls. Your tool calls may not be shown directly in the output, so text like \"Let me read the file:\" followed by a read tool call should just be \"Let me read the file.\" with a period."_.
- **Close diagnostic flows with plain-language explanation and next steps.** End an investigation by demanding actionable output, not a log dump. _"Explain what you found in plain language"_ / _"Suggest concrete fixes or next steps"_.
- **Encode the step relationship in the identifier, not the prose.** When emitting a numbered procedure, let concurrent steps share a number with letter suffixes so the IDs themselves carry the parallelism. _"Steps that can run concurrently use sub-numbers: 3a, 3b"_.
- **Phrase a section header as the action-cue at the decision point, not an abstract noun.** With identical body text, an action-cue header ("Before recommending") measurably outperformed an abstract topic label ("Trusting what you recall") — name the rule by the moment it fires. _"\"Before recommending\" (action cue at the decision point) tested better than \"Trusting what you recall\" (abstract)."_

**Naturalism and precondition messages** — write realistic input, return useful failures:

- **Write example user turns as messy real input.** Lowercase, ungrammatical example utterances make the model generalize past polished prompts. _"so is the gate wired up or not"_.
- **Narrate tool actions in stage directions.** Depict actions inside transcript examples with asterisks instead of literal tool-call syntax, keeping examples readable. _"Assistant: \*Creates todo list with the following items:\*"_.
- **Calibrate verbosity to the prompt's role.** The same rule collapses to one clause in a reference prompt that an onboarding prompt spends a section on. _"Refer to teammates by name, never by UUID."_.
- **Hand the model the exact command for an obscure operation.** For non-obvious syntax, give the literal command, not an abstract description. _"View comments on a Github PR: gh api repos/foo/bar/pulls/123/comments"_.
- **Give the literal probe plus its OS variant.** Pair the exact detection command with its cross-platform form and the condition that gates the follow-up. _"GitHub CLI: Run `which gh` (or `where gh` on Windows). If it's missing AND the project uses GitHub (check `git remote -v` for github.com), ask the user if they want to install it."_.
- **Map natural phrasing to config values via an arrow table.** Translate the user's words into technical values and flag surprising behavior. _"\"after every edit\" → `PostToolUse` with matcher `Write|Edit`"_ and _"\"when ${MODEL_NAME} finishes\" / \"before I review\" → `Stop` event (fires at the end of every turn — including read-only ones)"_.
- **Give the exact command per environment variant.** Provide the precise invocation for each detected package manager rather than letting the model synthesize one. _"For npm: `npm install -D @playwright/test && npx playwright install`"_ / _"For yarn: `yarn add -D @playwright/test && yarn playwright install`"_.
- **Format warnings through one shared sigil block.** Factor a `⚠ Heads-up:` formatter so the same notes render identically wherever they appear. _"⚠ Heads-up:\n${items}"_.
- **On a hard precondition failure, state blocker + unsupported case + recovery.** Return a terse text-only prompt naming the exact recovery command. _"You need to authenticate with a claude.ai account first. API accounts are not supported. Run /login, then try /schedule again."_.
- **On a transient failure, return a calm retry message.** Degrade to a user-facing retry rather than a stack trace or a prompt that proceeds without data. _"We're having trouble connecting with your remote claude.ai account to set up a scheduled task. Please try /schedule again in a few minutes."_.
- **Enumerate a closed value vocabulary with the default marked.** Define the allowed values, label the default, and say it can be omitted, so output stays terse. _"Execution: `Direct` (default), `Task agent` (straightforward subagents), `Teammate` (agent with true parallelism and inter-agent communication), or `[human]` (user does it). Only needs specifying if not Direct."_.

## Reference — XML tag taxonomy

| Tag                                                                                    | What it wraps                                                    | Role                                                                                                                             |
| -------------------------------------------------------------------------------------- | ---------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| `<system-reminder>`                                                                    | Meta-reminders injected by the harness                           | "Non-relational — bears no direct relation to the specific tool result it's attached to."                                        |
| `<example>`                                                                            | A complete multi-turn interaction                                | Specification the model pattern-matches against                                                                                  |
| `<thinking>`                                                                           | The _model's_ internal reasoning inside an example               | Teaches the expected decision pattern                                                                                            |
| `<commentary>`                                                                         | Meta-explanation of an example, for the reader                   | What this example is teaching; distinguishes coordinator turn from notification turn                                             |
| `<reasoning>`                                                                          | Justification after an example                                   | Teaches the decision _criteria_ behind the example (not the input→output mapping); also attached to negative / when-NOT examples |
| `<analysis>`                                                                           | Scratchpad for model reasoning before structured output          | Stripped before result is surfaced (compaction)                                                                                  |
| `<summary>`                                                                            | Structured summary output                                        | Downstream code parses this                                                                                                      |
| `<scope>`                                                                              | A task or agent's boundary statement                             | Used in memory types and agent briefings                                                                                         |
| `<type>`, `<name>`, `<when_to_save>`, `<how_to_use>`, `<body_structure>`, `<examples>` | Slots in memory-type taxonomy                                    | Declarative rules, one semantic slot per tag                                                                                     |
| `<env>`                                                                                | Environment metadata (cwd, git status, platform, shell)          | Single parseable block rather than inline prose                                                                                  |
| `<command-name>`                                                                       | Which slash command triggered the current expanded context       | Lets the model recognize "skill already loaded, don't re-invoke"                                                                 |
| `<user-prompt-submit-hook>`                                                            | Feedback from a user-prompt-submit shell hook                    | Treated as coming from the user                                                                                                  |
| `<tick>`                                                                               | Periodic wake-up marker in autonomous loops                      | _"You're awake, what now?"_ — distinguishes paced wake-ups from reactive user messages                                           |
| `<block>`                                                                              | Classifier verdict in permission / yolo classification           | Closed-world verdict, preceded by `<thinking>`                                                                                   |
| `<example_agent_descriptions>`                                                         | A fixture defining the cast of agents used by following examples | Makes examples self-contained                                                                                                    |
| `<code>`                                                                               | Source embedded inside an example                                | Distinguishes demonstrated code from prose instructions                                                                          |
| `<doc path="…">`                                                                       | One inlined reference file, with its origin path as an attribute | Preserves provenance when reasoning across many docs                                                                             |

**Tag-usage patterns:**

- **Wrap few-shot turns with explicit role prefixes.** Put demonstrations in `<example>` with `user:`/`assistant:` prefixes so the model parses turns unambiguously. _"<example>\nuser: \"Please write a function that checks if a number is prime\"\nassistant: I'm going to use the ${FILE_WRITE_TOOL_NAME} tool to write the following code:"_.
- **Show the decision in `<thinking>`.** Model the reasoning that selects a tool inside the example, teaching the decision process and not just the action. _"assistant: <thinking>Forking this — it's a survey question. I want the punch list, not the git output in my context.</thinking>"_.
- **Explain the example's lesson in `<commentary>`.** Use `<commentary>` for out-of-band rationale the model should not mistake for dialogue to emit. _"<commentary>\nSince a significant piece of code was written and the task was completed, now use the test-runner agent to run the tests\n</commentary>"_.
- **Fence example source in `<code>`.** Keep demonstrated code visually separate from instructions. _"<code>\nfunction isPrime(n) {\n if (n <= 1) return false\n …"_.
- **Define the example's cast in a fixture block.** Declare the agents the following examples reference so the examples stand alone. _"<example_agent_descriptions>\n\"test-runner\": use this agent after you are done writing code to run tests\n\"greeting-responder\": use this agent to respond to user greetings with a friendly joke\n</example_agent_descriptions>"_.
- **Wrap a copyable command template in `<example>` and state the why.** When the exact escaping matters, fence the template and explain the reason so the model reproduces it. _"<example>\ngit commit -m \"$(cat <<'EOF' … EOF\n )\"\n</example>"_.
- **Fence injected context and dynamic data in named XML tags.** Wrap runtime-injected state in a semantic tag so the model distinguishes data-to-reason-over from instructions. _"<session_memory>\n{{sessionMemory}}\n</session_memory>"_.
- **Carry provenance on each inlined doc tag.** Attach the original path as an attribute and explain the wrapper up front so the model can cite and locate sources. _"<doc path=\"${filePath}\">\n${processContent(md, content).trim()}\n</doc>"_ and _"The relevant documentation for your detected language is included below in `<doc>` tags. Each tag has a `path` attribute showing its original file path. Use this to find the right section:"_.

**Schema-in-prose patterns** (closed enums and commented JSON, where XML tags are overkill):

- **Define a state machine as named states with a one-line gloss each.** A closed list with glosses makes the schema self-documenting. _"pending: Task not yet started\nin_progress: Currently working on (limit to ONE task at a time)\ncompleted: Task finished successfully"_.
- **Document the input contract as a fully commented JSON literal.** Annotate every field with an inline `//` explanation and an example value so the agent knows what it can read. _"1. The statusLine command will receive the following JSON input via stdin:\n {\n \"session_id\": \"string\", // Unique session ID"_.
- **Annotate every nullable field with its absent case.** Say when a field is null or missing so generated code defends against the empty case. _"\"current_usage\": { // Token usage from last API call (null if no messages yet)"_.
- **Pretty-print injected structured state inside a fenced `json` code block.** Hand the model state as fenced JSON so it parses cleanly and reads as separate from prose. _"**User's settings.json:**\n`json\n${settingsJson}\n`"_.

## Reference — template variables

| Variable                            | Substitutes to                                              | When to use                                                                                                                                |
| ----------------------------------- | ----------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `$ARGUMENTS`                        | The full raw argument string                                | Single-arg skills, or when you want the whole string                                                                                       |
| `$ARGUMENTS[0]`, `$ARGUMENTS[1]`, … | Individual shell-quoted tokens                              | Positional args                                                                                                                            |
| `$0`, `$1`, `$2`, …                 | Shorthand for `$ARGUMENTS[N]`                               | Same as above                                                                                                                              |
| `$name`                             | The Nth positional arg (if `arguments: [name, …]` declared) | Named-arg skills                                                                                                                           |
| `${CLAUDE_SKILL_DIR}`               | The skill's own directory                                   | Reference bundled scripts / schemas, e.g. `${CLAUDE_SKILL_DIR}/helper.sh` or `${CLAUDE_SKILL_DIR}/references/claude-code/architectures.md` |
| `${CLAUDE_SESSION_ID}`              | Current session ID                                          | Namespace per-session scratch files                                                                                                        |
| `` !`command` ``                    | Live stdout of `command` run at expansion time              | Inject `git status`, `git diff`, etc. Subject to the skill's `allowed-tools`.                                                              |

Also seen at build time in production prompt constants (not for your own skills, but useful to recognize when reading prompt source): `${AGENT_TOOL_NAME}`, `${BASH_TOOL_NAME}`, `${FILE_READ_TOOL_NAME}`, `${SKILL_TOOL_NAME}`, `${ASK_USER_QUESTION_TOOL_NAME}`, `${TICK_TAG}`, `${COMMAND_NAME_TAG}`.

**Cross-reference by constant, never by literal.** Reference sibling tools through an imported name constant so prompt cross-references never drift on a rename. _"import { ASK_USER_QUESTION_TOOL_NAME } from '../AskUserQuestionTool/prompt.js'"_, _"use ${EXIT_PLAN_MODE_TOOL_NAME} for plan approval"_. When you must deviate, justify it: _"// Hardcoded to avoid relative import issues in stub\nconst ASK_USER_QUESTION_TOOL_NAME = 'AskUserQuestion'"_.

**Build dynamic prompts from a function, not a static const.** Compute environment-dependent text fresh at call time and `.trim()` the template literal so backtick newlines don't bleed in. _"export function getWebSearchPrompt(): string {\n const currentMonthYear = getLocalMonthYear()\n return `"_, _"export function getExitWorktreeToolPrompt(): string {\n return `Exit a worktree session created by EnterWorktree"_, _"`.trim()"_.

**Inject live runtime values so the model never guesses.** Pull limits, paths, and identity straight from the source the runtime enforces, rendering both raw and human units where useful:

- **Numeric limits from the enforcing constant.** _"You may specify an optional timeout in milliseconds (up to ${getMaxTimeoutMs()}ms / ${getMaxTimeoutMs() / 60000} minutes). By default, your command will timeout after ${getDefaultTimeoutMs()}ms (${getDefaultTimeoutMs() / 60000} minutes)."_. Name magic-number bounds as constants and interpolate them: _"const MIN_AGENTS = 5\nconst MAX_AGENTS = 30"_.
- **The machine config itself, serialized.** Show the model its own cage so it reasons over actual paths/hosts. _"restrictionsLines.push(`Filesystem: ${jsonStringify(filesystemConfig)}`)"_.
- **Resolved absolute paths, not abstract names.** _"\* user - ${getSettingsFilePathForSource('userSettings')}\n\* project - ${getSettingsFilePathForSource('projectSettings')}\n\* local - ${getSettingsFilePathForSource('localSettings')}"_.
- **Identity the model will need downstream.** _"- `SAFEUSER`: ${safeUser}\n- `whoami`: ${username}"_.
- **Time-sensitive text from a helper.** _"const currentMonthYear = getLocalMonthYear()"_.
- **Model self-identity and staleness.** _"You are powered by the model named ${marketingName}. The exact model ID is ${modelId}."_ and _"Assistant knowledge cutoff is ${cutoff}."_.
- **An in-context default that beats stale priors.** _"When building AI applications, default to the latest and most capable ${MODEL_NAME} models."_.
- **An output-language lock with a code-identifier exemption.** _"Always respond in ${languagePreference}. Use ${languagePreference} for all explanations, comments, and communications with the user. Technical terms and code identifiers should remain in their original form."_.
- **Restate a renamed product in prose.** When an API or product has been renamed, name the old term parenthetically in the prompt itself so the model recognizes users on stale vocabulary and maps it to the current name. _"The Claude API (formerly known as the Anthropic API) for direct model interaction"_.

**Splice optional fragments without leaving orphan blank lines.** Append the trailing newline inside the conditional so an omitted fragment renders cleanly. _"${backgroundNote ? backgroundNote + '\\n' : ''}\\"_; gate optional sections as interpolated fragments — _"const udsRow = feature('UDS_INBOX')\n ? `\\n| \\`\"uds:/path/to.sock\"\\` | Local ${MODEL_NAME} session's socket. |\` : ''"_.

**Append freeform user args under a labeled trailing section.** Splice user input under its own header — never raw-concatenated — so the model treats it as scoped context, not core spec, and an empty arg leaves no dangling stanza:

- _"if (args) {\n prompt += `\\n\\n## Additional Focus\\n\\n${args}`\n }"_, _"prompt += `\\n## User-provided context\\n\\n${args}\\n`"_, _"prompt += `\\n\\nAdditional Instructions:\\n${customInstructions}`"_, _"promptContent += `\\n\\n## Additional instructions from user\\n\\n${trimmedArgs}`"_.
- Guard the append behind a presence check with a label: _"${args ? 'Additional user input: ' + args : ''}"_.
- Echo the raw instruction back under its own heading as a stable anchor for later steps: _"## User Instruction\n\n${instruction}"_.
- Place the data at the bottom under a final heading so all parsing rules precede it: _"## Input\n\n${args}"_, _"PR number: ${args}"_.
- When an optional arg is empty, substitute a full fallback instruction so the section is never blank: _"${args || 'The user did not describe a specific issue. Read the debug log and summarize any errors, warnings, or notable issues.'}"_.
- Reserve a leading prefix slot for environment-specific instructions injected ahead of the standard template: _"let prefix = ''\n if (process.env.USER_TYPE === 'ant' && isUndercover()) {\n prefix = getUndercoverInstructions() + '\\n'\n }\n\n return `${prefix}## Context"_.

**Provide fill-in-the-blank skeletons with self-describing slots.** Hand the model the exact artifact shape so it never invents a layout; make each placeholder a sentence that describes what to put there, and mark `<repeat>`/`omit` cases explicitly:

- _"## Summary\n<1-3 bullet points>\n\n## Test plan\n[Bulleted markdown checklist of TODOs for testing the pull request...]"_.
- Mustache placeholders annotated as their own spec: _"Use this format:\n\n```markdown\n---\nname: {{skill-name}}\ndescription: {{one-line description}}"_ and _"when_to_use: {{detailed description of when ${MODEL_NAME} should automatically invoke this skill, including trigger phrases and example user messages}}"_; splice optional context right in the title region: _"# Skillify {{userDescriptionBlock}}"_.
- Angle-bracket placeholders with inline conditional instructions and an explicit omit case: _"## Authentication\n<If auth is required, include step-by-step login instructions here>\n<Include login URL, credential env vars, and post-login verification>\n<If no auth needed, omit this section>"_.
- Filled-in table skeletons with placeholder rows guarantee output shape: _"| # | Unit | Status | PR |\n|---|------|--------|----|\n| 1 | <title> | running | — |\n| 2 | <title> | running | — |"_.
- Verbatim prefix blocks in a fenced code block force copy-not-paraphrase: _"Prefix the file with:\n\n`\n# CLAUDE.md\n\nThis file provides guidance to ${AGENT_HARNESS} (claude.ai/code) when working with code in this repository.\n`"_.
- Spell out multiple-choice option strings and a per-option description so the generated UI is consistent: _"Options: \"Project CLAUDE.md\" | \"Personal CLAUDE.local.md\" | \"Both project + personal\"\n Description for project: \"Team-shared instructions checked into source control — architecture, coding standards, common workflows.\""_.
- Two example rows (not one) signal a variable-length repeating list: _"- [Source Title 1](https://example.com/1)\n- [Source Title 2](https://example.com/2)"_.
- **Ship per-section authoring instructions as permanent in-file lines, not one-time slots.** Embed the guidance for each section inside the artifact as a preserved line the model writes _beneath_ rather than replaces, so the spec re-grounds every future edit without re-injection. _"The italic *section descriptions* are TEMPLATE INSTRUCTIONS that must be preserved exactly as-is … ONLY update the actual content that appears BELOW the italic *section descriptions*"_.

**Structure catalog entries and config in a fixed shape.** Render each catalog line in a parseable shape and pair description with `whenToUse`:

- _"return `- ${agent.agentType}: ${agent.whenToUse} (Tools: ${toolsDescription})`"_; each item as name + how-to + good-for — _"2. Custom Skills: Reusable prompts you define as markdown files that run with a single /command.\n - How to use: Create `.claude/skills/commit/SKILL.md` with instructions. Then type `/commit` to run it.\n - Good for: repetitive workflows"_.
- Keep the registered description to one clause; long-form guidance lives in the body — _"export const DESCRIPTION = 'Send a message to another agent'"_.
- Reference a schema field by its exact literal name and value, not prose: _"Use multiSelect: true to allow multiple answers to be selected for a question"_.
- Factor the family's shared identity line into a constant so every member inherits one voice: _"const SHARED_PREFIX = `You are an agent for ${AGENT_HARNESS}, ${VENDOR}'s official CLI for ${MODEL_NAME}. Given the user's message, you should use the tools available to complete the task. Complete the task fully—don't gold-plate, but don't leave it half-done.`"_.
- Model header-with-sub-bullets as a string-then-string[] so visual hierarchy is data-driven: _"const instructionItems: Array<string | string[]> = ["_.
- A tool prompt can follow a fixed H2 ordering from gating to mechanics to inputs: _"## When to Use\n\n## When NOT to Use\n\n## Requirements\n\n## Behavior\n\n## Parameters"_.
- Mark which argument value is the default right in the section header: _"## Recurring jobs (recurring: true, the default)"_.
- Annotate each scalar setting with its default and the meaning of edge values: _"`cleanupPeriodDays`: Days to keep transcripts (default: 30; 0 disables persistence entirely)"_.
- For a composite identifier, show the template form and enumerate the closed value set per part: _"Plugin syntax: `plugin-name@source` where source is `claude-code-marketplace`, `claude-plugins-official`, or `builtin`."_.
- Constrain capability at the harness level via a frontmatter allowlist that enforces the prose's read-only intent: _"allowed-tools: Bash(git diff:_), Bash(git status:_), Bash(git log:_), Bash(git show:_), Bash(git remote show:_), Read, Glob, Grep, LS, Task"_; least-privilege per generated variant — _"verifier-playwright:\n`yaml\nallowed-tools:\n  - Bash(npm:*)\n  …\n  - mcp__playwright__*\n  - Read\n  - Glob\n  - Grep\n`"\_.
- Short-circuit empty input into usage help before the model ever sees the task prompt: _"const instruction = args.trim()\n if (!instruction) {\n return [{ type: 'text', text: MISSING_INSTRUCTION_MESSAGE }]\n }"_.
- Substitute a single well-known token for runtime data, keeping the templating contract minimal: _"// Replace $ARGUMENTS with the JSON input\n const processedPrompt = addArgumentsToPrompt(hook.prompt, jsonInput)"_.
- Do template substitution in one regex pass with a replacer function — never sequential string replaces — because a single pass is the only thing that stops injected user content from corrupting output via `$` or getting re-expanded as a token: _"Single-pass replacement avoids two bugs: (1) $ backreference corruption (replacer fn treats $ literally), and (2) double-substitution when user content happens to contain {{varName}} matching a later variable."_.
- **Select get-vs-set by the presence of one optional parameter.** Make a single tool polymorphic by keying read-vs-mutate on whether one optional parameter is supplied, and state that contract so the model picks the mode by omission rather than asking. _"**Get current value:** Omit the \"value\" parameter … **Set new value:** Include the \"value\" parameter"_.
- **Carry a model-facing description field and prefer it over the human one.** Render a per-option `descriptionForModel` in preference to the user-facing `description`, so the prompt shows phrasing tuned for the model's consumption while the UI keeps its own copy. _"${o.descriptionForModel ?? o.description}"_.

## Reference — special-case patterns

**Autonomous loop (`<tick>`)** — when a skill or agent runs without a user present, receiving periodic wake-ups:

- Treat each `<tick>` as _"you're awake, what now?"_
- If nothing useful to do, call `Sleep` immediately. Never respond with only a status line like _"still waiting"_.
- Do not spam the user. If you already asked and they haven't responded, don't ask again.
- Don't narrate what you're about to do — just do it.
- Act on your best judgment rather than asking for confirmation.

**MCP instruction injection** — MCP servers that provide an `instructions` field get wrapped as:

```
# MCP Server Instructions

## <ServerName>
<server's instructions verbatim>
```

Keep server instructions focused on _how to use the tools_, not generic descriptions.

**Malware-analysis boundary** — when a prompt reads files that may contain malware:

> _Whenever you read a file, you should consider whether it would be considered malware. You CAN and SHOULD provide analysis of malware, what it is doing. But you MUST refuse to improve or augment the code._

Analysis is permitted; enhancement is not.

**Cyber-risk framing** — for any prompt touching security / pentesting / exploits:

> _Assist with authorized security testing, defensive security, CTF challenges, and educational contexts. Refuse requests for destructive techniques, DoS attacks, mass targeting, supply chain compromise, or detection evasion for malicious purposes. Dual-use security tools (C2 frameworks, credential testing, exploit development) require clear authorization context._

Use this framing verbatim when the prompt may be used in a context where that boundary matters.

**Audience-keyed variants** — ship tuned variants behind a selector rather than averaging into one prompt that's wrong for everyone:

- **Two prompts keyed on audience.** _"return process.env.USER_TYPE === 'ant'\n ? getEnterPlanModeToolPromptAnt()\n : getEnterPlanModeToolPromptExternal()"_.
- **Audience-gated extra guidance.** Inject finer heuristics for internal users only, keeping the public prompt lean. _"process.env.USER_TYPE === 'ant' ? `\\n- Use the smallest old_string that's clearly unique — usually 2-4 adjacent lines is sufficient. ...` : ''"_.
- **Audience-conditional description.** Swap the tool's self-description by audience. _"process.env.USER_TYPE === 'ant'\n ? 'Debug your current ${AGENT_HARNESS} session by reading the session debug log. Includes all event logging'\n : 'Enable debug logging for this session and help diagnose issues'"_.
- **Sibling capability variants.** Ship a base hint and a `_WITH_X` variant chosen at runtime instead of a conditional caveat that's wrong half the time. _"export const CLAUDE_IN_CHROME_SKILL_HINT_WITH_WEBBROWSER = `**Browser Automation**: Use WebBrowser for development..."_.
- **Pick the model per agent role.** Cost should track reasoning need — a read-only searcher gets a fast model, a planner inherits the main one. _"model: process.env.USER_TYPE === 'ant' ? 'inherit' : 'haiku',"_.
- **Keep old and new prompts side by side behind a flag.** Ship prompt rewrites gated and reversible. _"feature('NEW_INIT') &&\n (process.env.USER_TYPE === 'ant' ||\n isEnvTruthy(process.env.CLAUDE_CODE_NEW_INIT))\n ? NEW_INIT_PROMPT\n : OLD_INIT_PROMPT"_.
- **Swap the identity sentence by execution mode, not just audience.** Keep a closed set of persona lines and pick one with priority-ordered first-match branches on launch signals (provider, interactivity, whether the caller appended its own prompt), falling through to the plain default — so the identity the model adopts tracks how it was launched. _"You are ${AGENT_HARNESS}, ${VENDOR}'s official CLI for ${MODEL_NAME}, running within the ${AGENT_HARNESS} SDK."_ / _"You are a ${MODEL_NAME} agent, built on ${VENDOR}'s ${AGENT_HARNESS} SDK."_.

**Feature-flag whole sections** — gate sections on runtime flags so disabled capabilities never appear and never conflict with guidance delivered elsewhere:

- Splice a section out when its feature is on (because the instructions arrive via another channel): _"const whatHappens = isPlanModeInterviewPhaseEnabled()\n ? ''\n : WHAT_HAPPENS_SECTION"_.
- Inject a whole section only when a runtime condition holds, narrating state the model can't otherwise know: _"const justEnabledSection = wasAlreadyLogging\n ? ''\n : `\n## Debug Logging Just Enabled\n\nDebug logging was OFF for this session until now. Nothing prior to this /debug invocation was captured."_.
- Build prompts from togglable string slots so a mode can blank out reviewer tags, changelog, and Slack steps without a separate template: _"if (process.env.USER_TYPE === 'ant' && isUndercover()) {\n prefix = getUndercoverInstructions() + '\\n'\n reviewerArg = ''\n addReviewerArg = ''\n changelogSection = ''\n slackStep = ''\n }"_; inject attribution trailers only when configured: _"Commit message here.${commitAttribution ? `\\n\\n${commitAttribution}` : ''}"_.
- Gate a skill's availability on a feature-flag predicate so it only registers when its backing capability exists: _"isEnabled: isKairosCronEnabled,"_.
- Mark a public stub file and name the internal section it omits: _"// External stub for ExitPlanModeTool prompt - excludes Ant-only allowedPrompts section"_.
- **Measure the artifact in code and splice an escalating budget warning only when breached.** Compute live token counts and inject a condensation directive only over budget — escalating wording per threshold.

**Registration scoping** — control who can invoke and how, at the registration layer:

- Gate a destructive/expensive skill to user invocation only so the model can't trigger a 30-agent fan-out: _"userInvocable: true,\n disableModelInvocation: true,"_.
- Gate an internal-only skill behind an env check at registration so it never appears for external users: _"if (process.env.USER_TYPE !== 'ant') {\n return\n }"_.
- Pair description with a `whenToUse` that names the trigger and key qualifier, and ends with a `Do NOT` clause to carve away the nearest mis-trigger: _"whenToUse:\n 'Use when the user wants to make a sweeping, mechanical change across many files (migrations, refactors, bulk renames) that can be decomposed into independent parallel units.'"_.
- Suppress permission prompts for a purely read-and-fetch agent, trading a confirmation gate for fluency because it cannot mutate state: _"permissionMode: 'dontAsk',"_.
- Set expectations (duration, where it runs, terms link) in the command description so the user consents before a slow/remote action triggers: _"~10–20 min · Finds and verifies bugs in your branch. Runs in ${AGENT_HARNESS} on the web. See ${CCR_TERMS_URL}"_.
- **Withhold model invocation on a generated side-effecting skill.** When emitting a skill whose action has side effects, set `disable-model-invocation: true` so only the user can fire it and wire `$ARGUMENTS` for input. _"For workflows with side effects (e.g., `/deploy`, `/fix-issue 123`), add `disable-model-invocation: true` so only the user can trigger it, and use `$ARGUMENTS` to accept input."_.

**Environment-aware assembly** — name tools, paths, and platforms that actually exist at runtime:

- Branch wording on the runtime toolset so instructions always name real tools: _"const globGuidance = embedded\n ? `- Use \\`find\\` via ${BASH_TOOL_NAME} for broad file pattern matching`\n : `- Use ${GLOB_TOOL_NAME} for broad file pattern matching`"_.
- Compute the exact format string the model must reason about from the same flag that controls real output: _"const prefixFormat = isCompactLinePrefixEnabled() ? 'line number + tab' : 'spaces + line number + arrow'"_.
- Inline platform gotchas where the shell is declared: _"Shell: ${shellName} (use Unix shell syntax, not Windows — e.g., /dev/null not NUL, forward slashes in paths)"_.
- Inject a hazard warning only when its condition holds: _"This is a git worktree — an isolated copy of the repository. Run all commands from this directory. Do NOT `cd` to the original repository root."_.
- Name the exact rendering spec so formatting ambiguity disappears: _"You can use Github-flavored markdown for formatting, and will be rendered in a monospace font using the CommonMark specification."_; tell the model which fields accept rich formatting and which are plain: _"The `preview` field renders markdown in a side-panel (like plan mode); the `question` field is plain-text-only."_.
- Surface a harness affordance the model wouldn't otherwise know, with a concrete trigger: _"If you need the user to run a shell command themselves (e.g., an interactive login like `gcloud auth login`), suggest they type `! <command>` in the prompt — the `!` prefix runs the command in this session so its output lands directly in the conversation."_; tell the agent how to acquire a deferred tool on demand: _"Use ToolSearch to find `slack_send_message` if it's not already loaded."_.
- Teach the escape mechanism for arguments the parser would eat, with the exact trigger characters and a working example: _"For arguments containing `-`, `@`, or other characters PowerShell parses as operators, use the stop-parsing token: `git log --% --format=%H`"_.
- **Name the engine to override a near-miss syntax prior.** When the tool's dialect differs subtly from a near-identical one the model already knows, name the exact engine and show the single divergence point with a worked escape. _"Uses ripgrep (not grep) - literal braces need escaping (use `interface\{\}` to find `interface{}`)"_.
- **Show the reconciled effective set, not the raw config.** When two config layers both gate a capability (allowlist plus denylist), render the intersection the runtime will actually honor — collapsing an empty result to `None` — so the prompt never overstates what the agent can do. _"Both defined: filter allowlist by denylist to match runtime behavior … const effectiveTools = tools.filter(t => !denySet.has(t))"_.
- Reconcile inherited context against a separate working copy: re-root the parent's paths and re-read possibly-stale files before editing. _"Paths in the inherited context refer to the parent's working directory; translate them to your worktree root. Re-read files before editing if the parent may have modified them since they appear in the context."_.

**Instruction-file organization** — structuring always-loaded instruction artifacts (CLAUDE.md, rules files):

- **Split mixed concerns into path-scoped rule files.** When one instruction file would blend unrelated topics, propose separate auto-loaded files under `.claude/rules/` scoped by `paths` frontmatter instead of a monolith. _"suggest organizing instructions into `.claude/rules/` as separate focused files … scoped to specific file paths using `paths` frontmatter"_.
- **Defer bulk or volatile content to an `@path` import.** In an always-loaded artifact, replace long references and fast-rotting data with an `@path/to/import` so the content loads on demand instead of bloating the file, and a live source is read fresh instead of staling. _"use `@path/to/import` syntax instead (e.g., `@docs/api-reference.md`) to inline content on demand without bloating CLAUDE.md … reference the source with `@path/to/import` so ${MODEL_NAME} always reads the current version"_.
- **Route a generated file's storage by topology, sharing one source via an import stub.** When co-located storage breaks (sibling/external worktrees the upward walk can't reach), hoist the real content to a home-dir file and have each consumer carry a one-line `@import` stub pointing at it. _"the personal content should live in a home-directory file (e.g., `~/.claude/<project-name>-instructions.md`) and each worktree gets a one-line CLAUDE.local.md stub that imports it: `@~/.claude/<project-name>-instructions.md`"_.

**Edge cases and degradation** — pre-empt the failure mode rather than letting it surface:

- Suppress a redundant action by returning a stub that states why and points at where the still-valid data lives: _"File unchanged since last read. The content from the earlier Read tool_result in this conversation is still current — refer to that instead of re-reading."_.
- Pre-empt a filesystem edge case so an edit lands on the real file: _"If ~/.claude/settings.json is a symlink, update the target file instead."_.
- Encode hard-won operational knowledge as a narrow conditional so generated scripts don't deadlock: _"If the script includes git commands, they should skip optional locks"_.
- Document a non-obvious sentinel value and its effect: _"Set `commit` or `pr` to empty string `\"\"` to hide that attribution."_.
- Name the exact field-to-field wiring needed to link two tool calls: _"Pass the top-level message's `ts` as `thread_ts`."_.
- Handle the degenerate empty-data branch explicitly so the model pivots usefully: _"If auto-memory is empty, say so and offer to review CLAUDE.md for cleanup."_.
- On detection failure, degrade by including everything and instructing the model to ask the disambiguating question: _"No project language was auto-detected. Ask the user which language they are using, then refer to the matching docs below."_.
- Wrap an injected diagnostic whose failure is informative-but-not-fatal so the Context shows a clean empty result, not a scary error: _"`gh pr view --json number 2>/dev/null || true`: !`gh pr view --json number 2>/dev/null || true`"_.
- Even with a strict only-JSON instruction, defensively extract the brace span so stray prose doesn't break parsing: _"const jsonMatch = text.match(/\\{[\\s\\S]\*\\}/)\n if (!jsonMatch) return null"_.
- **Degrade a dynamic option list to a static prose fallback.** When live enumeration of a setting's options can throw, wrap it in try/catch and fall back to a hardcoded list of the same options so the prompt never ships an empty or broken menu. _"} catch { return `## Model\n- model - Override the default model (sonnet, opus, haiku, best, or full model ID)`"_.

**Domain-fact carve-outs** (security review) — encode what the target tech makes impossible so the model stops reporting noise, and keep gates aligned with stated bands:

- Language-level impossibility: _"Memory safety issues such as buffer overflows or use-after-free-vulnerabilities are impossible in rust. Do not report memory safety issues in rust or any other memory safe languages."_.
- Constrain an over-broad class to its exploitable subset: _"SSRF vulnerabilities that only control the path. SSRF is only a concern if it can control the host or protocol."_.
- Declare a trendy-but-noisy class out of scope outright: _"Including user-controlled content in AI system prompts is not a vulnerability."_.
- Grant a stated simplifying assumption to kill a theoretical-only class: _"UUIDs can be assumed to be unguessable and do not need to be validated."_.
- Encode framework guarantees and their named escape hatches: _"React and Angular are generally secure against XSS. ... Do not report XSS vulnerabilities in React or Angular components or tsx files unless they are using unsafe methods."_.
- State which layer owns a responsibility so the model stops flagging the layer that legitimately delegates: _"A lack of permission checking or authentication in client-side JS/TS code is not a vulnerability. Client-side code is not trusted and does not need to implement these checks, they are handled on the server-side."_.
- **Anti-pattern — gate/band mismatch.** Keep rubric boundaries and numeric gates aligned. _"Filter out any vulnerabilities where the sub-task reported a confidence less than 8."_ cuts at <8 while the 1–10 rubric calls 7–10 "high confidence," silently dropping 7s.
- **Anti-pattern — duplicate manual numbering.** Long hand-numbered rule blocks drift; prefer unnumbered bullets or generated numbering. _"16. Regex DOS concerns.\n> 16. Insecure documentation. Do not report any findings in documentation files such as markdown files."_.

**Annotate design rationale and provenance in comments** — record the _why_ of a prompt decision beside the code so future editors don't undo it:

- Document why context is omitted to save tokens: _"// Explore is a fast read-only search agent — it doesn't need commit/PR/lint\n // rules from CLAUDE.md. The main agent has full context and interprets results.\n omitClaudeMd: true,"_.
- Note that standard guidance is appended elsewhere so a reader doesn't duplicate it: _"// Note: absolute-path + emoji guidance is appended by enhanceSystemPromptWithEnvDetails."_.
- Record routing/scoping invariants the prompt depends on: _"// /ultrareview is the ONLY entry point to the remote bughunter path —\n// /review stays purely local."_.
- Annotate when embedded shell commands are instructions-for-the-model, not host code: _"// Prompt text contains `ps` commands as instructions for ${MODEL_NAME} to run,\n// not commands this file executes."_.
- Document a lazy-load motivated by memory cost: _"// claudeApiContent.js bundles 247KB of .md strings. Lazy-load inside\n// getPromptForCommand so they only enter memory when /claude-api is invoked."_.
- **Record in a comment that the model can't introspect its own runtime dialect.** Note in build-time prose that the model's training spans multiple runtime editions but it cannot tell which one it executes in, so detection-driven injection resolves an ambiguity the model can't resolve itself. _"The model's training data covers both editions but it can't tell which one it's targeting, so it either emits pwsh-7 syntax on 5.1 (parser error → exit 1) or needlessly avoids && on 7"_.
- **Document why an intentional duplication is safe, so it isn't deduped away.** When a fork's prompt deliberately repeats rules already in the parent's system prompt, record the firing condition that makes the overlap harmless so a future editor doesn't "clean it up" and break the fallback. _"This prompt fires only when the main agent didn't write, so the save-criteria here overlap the system prompt's harmlessly."_.
- Ship a leak-prevention gate fail-safe-ON with no off switch: default the protective mode for every ambiguous, unconfirmed, or null state and provide no override at all, so the only exit is positive confirmation that protection is unnecessary — the inverse of a narrow-override default, justified by the asymmetric cost of a leak. _"There is NO force-OFF. This guards against model codename leaks — if we're not confident we're in an internal repo, we stay undercover."_.
- **Cap an always-present listing's per-entry size with the discovery-vs-full-load rationale.** Record in a build-time comment why each entry of an always-injected tool/skill index is capped: the listing only needs to enable matching, and full content loads on invoke, so verbose entries burn turn-1 cache-creation tokens without improving match rate. _"The listing is for discovery only — the Skill tool loads full content on invoke, so verbose whenToUse strings waste turn-1 cache_creation tokens without improving match rate."_.
- **Prune a build-registered entry when a runtime kill-switch disables it.** When a capability is registered at build time but gated by a live flag, filter that single entry out of the generated menu so the model never offers a setting that is currently switched off, and note the split in a comment. _"Voice settings are registered at build-time but gated by GrowthBook at runtime. Hide from model prompt when the kill-switch is on."_.

**Compose, don't average** — reuse shared fragments and assemble around markers rather than blending:

- Compose related agents by importing one's config and the shared read-only banner into another: _"tools: EXPLORE_AGENT.tools,"_.
- Assemble the final prompt by slicing a master SKILL.md at named section headers so authored prose and runtime-built sections interleave deterministically, and explicitly carry forward authored failure-mode sections: _"const readingGuideIdx = cleanPrompt.indexOf('## Reading Guide')"_ and _"// Preserve the \"When to Use WebFetch\" and \"Common Pitfalls\" sections\n const webFetchIdx = cleanPrompt.indexOf('## When to Use WebFetch')"_.
- Strip authoring-only HTML comments from reference docs before injection so the model never reads maintainer notes: _"// Strip HTML comments. Loop to handle nested comments."_.
- Construct an optional sentence in code so the prompt reads naturally with or without it, never leaving a dangling label: _"const userDescriptionBlock = args\n ? `The user described this process as: \"${args}\"`\n : ''"_.

**Self-referential dataset hygiene** — a pipeline that logs its own API calls can fingerprint and exclude its own meta-sessions from its dataset: _"content.includes('RESPOND WITH ONLY A VALID JSON OBJECT') ||\n content.includes('record_facets')"_.
