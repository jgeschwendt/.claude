# Keep-list discriminators (K-series)

The load-bearing/counterfeit specimen pairs behind `../SKILL.md` § Keep-list, one entry per category. The desk-test series — R, B, M, S, W, P, U, G — live in `catalog.md`, whose `## Using this catalog` rules govern this file too: anchor form, citation form, and the duty to re-anchor a specimen in the same pass that cuts the text it quotes. Id-cites into those series (`→ R4`, `→ P6`) resolve in `catalog.md`, and so do its tail sections — `## Counter-evidence` addresses §K by name ("Hold these against every keep verdict in §K") and `## Provenance caveats` is catalog-wide, so both govern the entries here.

## Contents

- **§K · Keep-list discriminators**: K1 bracketing · K2 cross-framing repetition · K3 trigger vocabulary · K4 distinct-from boundary · K5 rationale · K6 exemplars · K7 output specimen · K8 tempting-trivial enumeration · K9 escape hatch and bound · K10 headings and tables · K11 priority markers · K12 parser scaffolding · K13 consumer sentence · K14 null-branch blessing · K15 numbers and thresholds · K16 quoted literals · K17 cross-context duplication · K18 named diagnostic · K19 provenance stamp · K20 incident Why-line · K21 observed-surprise caveat · K22 per-step success criteria · K23 default-suppressing clause · K24 cited measurement · K25 declared-mirror fence · K26 product-consistency instruction

## K · Keep-list discriminators

Over-cutting breaks prompts silently: a lost constraint reads as clean prose, and constraint compliance degrades before semantic content under compression (arXiv:2512.17920). A cut touching any category here ships the rung-3 run that adjudicated it as its named regression input, or a KEEP verdict with its one-line reason (`../SKILL.md` § Keep-list) — a desk verdict does not satisfy it. Standing evidence for the whole section: arXiv:2510.00231 ("The Pitfalls of KV Cache Compression" — "certain instructions degrade much more rapidly with compression, effectively causing them to be completely ignored"); arXiv:2605.17304 ("Compress the Context, Keep the Commitments" — enumerate commitments before cutting, measure recall after).

### K1 · Bracketing

- **Discriminator** — four desk gates, all must pass: (1) the unit has a middle (>~40 lines); (2) the bracketed rule's violation is unrecoverable or invisible; (3) brackets number one, at most two, per artifact — a third proves none is the pivot; (4) the trailer sits inside the compaction budget (→ P6). Live gate: delete the trailer, run a long session or append adversarial user content, count violations.
- **Pattern** — `rg -nF '<the rule as a distinctive 6-word phrase>' <file>` and count hits.
- **Specimen** — Load-bearing: the compaction prompt opens `CRITICAL: Respond with TEXT ONLY. Do NOT call any tools.` and closes `REMINDER: Do NOT call any tools … Tool calls will be rejected and you will fail the task.` One rule, unrecoverable failure, both privileged slots, penalty named in the trailer. Counterfeit: a 45-line standup skill closing with `## Remember` / "Always be thorough and accurate. The user is trusting you… so quality is key." — no single constraint, no middle, no penalty.
- **Source** — `skills/craft-prompt/references/techniques.md` § Persistence and throttling; `skills/craft-prompt/references/transformations.md` T2 move 9; arXiv:2510.00231; code.claude.com/docs/en/skills (fetched 2026-07-29).

### K2 · Cross-framing repetition

- **Discriminator** — enumerate the restatements and write, for each, the one-sentence failure it uniquely closes. A restatement whose failure sentence duplicates another's is a copy. One that closes a route no other statement covers — a different decision point, output channel, or reading of the request — stays. Live: remove one restatement at a time and run the adversarial input aimed at that route.
- **Pattern** — none; enumerate per rule.
- **Specimen** — Load-bearing: EnterWorktree fences one tool three ways — the lede ("Use this tool ONLY when explicitly instructed to work in a worktree"), a When-NOT-to-use list of near-miss requests ("create a branch", "fix a bug"), and a flat never-clause ("Never use this tool unless 'worktree' is explicitly mentioned"). Each blocks a different reading. Counterfeit: three `IMPORTANT:` bullets inside one step ("keep it concise" / "use plain language" / "no sensitive information") — three unrelated rules wearing one marker, zero second-route coverage.
- **Source** — `skills/craft-prompt/references/techniques.md` § Scope, Authorization & Escape-Hatch Fences; § Closed-World Enumeration.

### K3 · Trigger vocabulary

- **Discriminator** — a phrase earns its tokens iff deleting it flips at least one should-trigger case. Run the description-tuning eval rather than a style read: write 10 should-trigger requests in the user's own vocabulary and 10 should-not-trigger near-misses, then measure hit rate with and without the candidate phrase. Mechanical cuts: a candidate sharing a stem or morphology with a phrase already present is cuttable; a different lexical field is not. Authoring cap: Claude Code truncates combined `description` + `when_to_use` at 1,536 characters in the listing, so cut TO the cap with the key use case first, never past it. PROTECTED surface: propose via AskUserQuestion, never auto-edit.
- **Pattern** — `rg -o '"[^"]+"' SKILL.md | head -30` then stem-compare.
- **Specimen** — Load-bearing: monitor-github's description carries "what's waiting on me", "any PRs I need to review?", "did CI pass?", "was I mentioned anywhere?", "even if they never say the word 'GitHub'" — no shared stems, each covers a phrasing the others miss. Counterfeit: "Use when the user wants to review, wants a review, needs reviewing, or asks for a code review." — one stem, four times.
- **Source** — code.claude.com/docs/en/skills (1,536-char listing cap, "Put the key use case first" — verified 2026-07-29); `skills/monitor-github/SKILL.md` frontmatter `description`; `skills/gigarefine/SKILL.md` § Rules (public-surface rule).

### K4 · Distinct-from boundary

- **Discriminator** — for every "do not use for X" row, name the artifact that SHOULD handle X. A row with a named competitor and a redirect in the same breath is load-bearing. A row fencing off something no router would send here is speculative padding. An observed mis-trigger (cite the transcript) also earns the row. Cut only when the named neighbour no longer exists.
- **Pattern** — `rg -in 'distinct from|do not use (this )?(skill )?for|not for '`
- **Specimen** — Load-bearing: gigasweep's "Distinct from /gigareview (this session's work-product), /code-review (a diff), /security-review (pending branch changes), and /gigadebug (starts from an observed failure)" — four real siblings with overlapping vocabulary, each redirected. Also `skills/pr-review/SKILL.md` frontmatter `when_to_use` ("the built-in `/review` is one-shot and stateless… round 3 cannot tell you whether round 1's objection was ever answered"). Counterfeit: a single-purpose standup skill's "Do not use this skill for generating changelogs, release notes, or commit messages… or if the user is not in a git repository." — no competitor, and the last clause defends a case the harness's own error already covers.
- **Source** — `skills/gigasweep/SKILL.md`; `skills/pr-review/SKILL.md` frontmatter `when_to_use`; `skills/craft-prompt/SKILL.md` principle 4 and § Minimum viable prompt anti-rule.

### K5 · Rationale

- **Discriminator** — the naming test: load-bearing rationale names a causal mechanism in vocabulary OUTSIDE the rule (a downstream consumer, a physical constraint, a named past incident, a blast radius) and decides a case the rule does not enumerate. Operational form: state, in one sentence, a case the rule omits but the rationale decides. Cannot → it is a restatement; cut. Substitution check: replace the rationale with "because I said so" and see whether an edge case becomes undecidable. Mechanism narration ("how it works") never earns tokens — this is the ruling on the vendor contradiction between "state what to do rather than narrating why" and "explain the why behind everything".
- **Pattern** — `rg -in '\b(because|since|so that|otherwise|which is why)\b'`
- **Specimen** — Load-bearing: "Your response will be read aloud by a text-to-speech engine, so never use ellipses since the text-to-speech engine will not know how to pronounce them." (generalizes unassisted to em-dashes, emoji, "etc."). "NEVER run destructive git commands… Taking unauthorized destructive actions is unhelpful and can result in lost work" (generalizes to commands the list omits). Counterfeit: "Never use ellipses, because ellipses should not be used." / "Be careful with git, because git is dangerous."
- **Source** — platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices § Add context to improve performance ("Claude is smart enough to generalize from the explanation"); `skills/craft-prompt/SKILL.md` principle 1 (fetched 2026-07-29).

### K6 · Exemplars

- **Discriminator** — name the decision each example disambiguates that NO rule states. Only answer is "it shows the rule being followed" → illustration; cut. Two examples on the SAME side of a boundary are one example: replace the second confirming case with the nearest reject case. Cross-boundary pairs stay. Ablation probe: hold rules fixed, delete the example, re-run its input plus one neighbor; output-shape drift is the evidence.
- **Pattern** — `rg -c '<example>' <file>`
- **Specimen** — Load-bearing: craft-prompt's `<example>` on "make this better: You are a helpful assistant that reviews PRs." whose `<thinking>` names the discriminator ("length is a signal, not a gate") and whose `<commentary>` names the prevented failure ("short pastes tempt the Draft branch, which would invent a new prompt") — neither stated in the routing table. Counterfeit: `<example>user: asks for a standup. assistant: produces a standup update.</example>`
- **Source** — arXiv:2605.20382 ("Do as I Say, Not as I Do" — instruction-following 1%–99% across 13 models as demonstrated-pattern pressure scales); `skills/craft-prompt/SKILL.md` principle 3.

### K7 · Output specimen

- **Discriminator** — parse test: construct one output satisfying every prose sentence of the format section that still breaks the consumer (prose preamble before the JSON, a markdown fence around it, reordered keys, trailing commentary, bold on a verdict literal). Such an output exists → the specimen is the fix and cannot be cut. Second gate: is the no-op branch rendered in the same wrapper? Genuinely cuttable: a second specimen of the same shape, or an "Example output" block re-listing the fields.
- **Pattern** — `rg -n 'ENTIRE response|exactly one of|no variation|first token'`
- **Specimen** — Load-bearing: `### <file>:<line> · <HIGH|MED|LOW>` / `**Issue:** <one sentence>` / `**Fix:** <the concrete change>` plus the null case in the same wrapper, `<updates>[]</updates>`. Counterfeit: "Please format your findings nicely so they're easy to read."
- **Source** — `skills/craft-prompt/references/diagnostics.md` § Output shape; `skills/craft-prompt/SKILL.md` §E.2; anthropic.com/engineering/writing-tools-for-agents.

### K8 · Tempting-trivial enumeration

- **Discriminator** — for each enumerated case, write the model's excuse for exempting it in one sentence. Can write the excuse → the enumeration is load-bearing, which is precisely why the case is named. No excuse available (the case is an ordinary member of the class) → cut; the general rule covers it. Live: run the enumerated case with its clause removed and check for the violation.
- **Pattern** — `rg -in 'even for|even when|including (the )?(trivial|simple|one-line)'`
- **Specimen** — Load-bearing: `Even for "hi". Even for "thanks."` on a rule that must fire every turn; the two-sided fence `PARTIAL is for environmental limitations only (no test framework, tool unavailable, server can't start) — not for "I'm unsure whether this is a bug."` Counterfeit: a twelve-item list of file extensions the rule applies to, none of which anyone would argue is exempt.
- **Source** — `skills/craft-prompt/references/diagnostics.md` § Rule-following ("Rationalizes exceptions ('surely not for THIS one')").

### K9 · Escape hatch and bound

- **Discriminator** — (a) can you write a plausible user request where the absolute is wrong and the user would clearly want it overridden? Yes → the hatch stays. No (policy removes the capability) → the hatch is the cut and the flat statement is stronger. (b) Can you write a case where the model reaches for the hatch to avoid work or judgment? Yes → the hatch's bound is not cuttable. Counterfeit signature, mechanically detectable: a hatch with no authorizing subject.
- **Pattern** — `rg -in 'unless (necessary|needed|appropriate|it (makes sense|seems))|if (appropriate|necessary)|at your discretion|as you see fit'` — every hit is a hatch authorizing the model.
- **Specimen** — Load-bearing: `NEVER run destructive git commands (push --force, reset --hard, checkout ., restore ., clean -f, branch -D) unless the user explicitly requests.` Load-bearing no-hatch: "the dangerouslyDisableSandbox parameter is disabled by policy. Commands cannot run outside the sandbox under any circumstances." Counterfeit: "Never edit files unless it seems necessary." / "unless necessary" / "if appropriate" / "when it makes sense".
- **Source** — `skills/craft-prompt/SKILL.md` principle 6; `skills/craft-prompt/references/techniques.md` § Anti-patterns ("Unbounded escape hatches… a hiding place for ordinary indecision").

### K10 · Headings and tables

- **Discriminator** — three checks. (1) Inbound reference: does any instruction elsewhere address this heading by name? A referenced heading is an address, and cutting it breaks navigation. (2) Order semantics: does row or bullet order encode routing precedence, priority ranking, or pipeline stages? Then the structure IS content. (3) Counterfeit: a heading with one sentence under it and no inbound reference, or a table column restating its neighbor — prove it by diffing information content cell by cell. Justify every structural token by the ambiguity it removes.
- **Pattern** — `rg -n '^#+ ' <file>` then `rg -n '§<heading>' ~/.claude`
- **Specimen** — Load-bearing: craft-prompt's routing table introduced by "First match wins — rows are ordered most-specific first", and its reference-library table whose `Load it when` column is the canonical statement of when each file gets read (nine inline pointers restate routes — the table is the authority, not the sole copy; corrected 2026-07-30 · craft-prompt run measured the claim). Counterfeit: `## Overview` above a single sentence; a three-column table whose third column paraphrases the second.
- **Source** — anthropic.com/engineering/effective-context-engineering-for-ai-agents; arXiv:2411.10541 (He et al., "Does Prompt Formatting Have Any Impact on LLM Performance?"); `skills/craft-prompt/SKILL.md` § When invoked; `rules/documentation.md` § Duplicated assertions.

### K11 · Priority markers

- **Discriminator** — a marker earns its tokens iff (a) the rule's violation is unrecoverable or silent AND (b) at least one comparable rule in the same section is left unmarked. With no unmarked neighbor the marker carries no contrast and is noise. Budget 1–3 per major section; over budget, rank by (a) and strip from the bottom, never uniformly. Blanket removal is a behavior change on the one rule that needed the marker; the adjudication runs at M5.
- **Pattern** — `rg -nc '\b(IMPORTANT|CRITICAL|MUST|NEVER|ALWAYS)\b' <file>`
- **Specimen** — Load-bearing: BashTool's single `IMPORTANT: Avoid using this tool to run cat, head, tail, sed, awk, or echo commands, unless explicitly instructed…` inside an otherwise unmarked usage-note list. Counterfeit: "IMPORTANT: Make sure to check for security vulnerabilities. / IMPORTANT: Also check for performance issues. / IMPORTANT: Code style is also very important." — replaced by one plain list in priority order, which encodes the weighting the caps were faking.
- **Source** — `skills/craft-prompt/SKILL.md` principle 8; `skills/craft-prompt/references/transformations.md` T1 move 4; `skills/craft-prompt/references/techniques.md` § Anti-patterns.

### K12 · Parser scaffolding

- **Discriminator** — precondition: the consumer is a parser, not a human. Adversarial-compliance test per field: construct a string satisfying every prose sentence that breaks the consumer. Exists → the closing text is load-bearing. Then the double-contract check, where the real cut lives: a constraint already enforced by a schema or enum the runtime validates makes the prose restatement a copy — keep the enforced one, cut the narration. Closed-world scaffolding on output a HUMAN reads is ceremony.
- **Pattern** — `rg -n 'exactly one of|no markdown|literal string|MUST begin with'`
- **Specimen** — Load-bearing: `Use the literal string "VERDICT: " followed by exactly one of PASS, FAIL, PARTIAL. No markdown bold, no punctuation, no variation.`; `Your ENTIRE response MUST begin with <block>`; one reserved sentinel (`respond with exactly "INVALID"`). Counterfeit: "Respond in a clear, structured format."; or the same three-value enum restated in prose, in the schema description, and in two examples for output no parser reads.
- **Source** — `skills/craft-prompt/SKILL.md` §E.2; `skills/craft-prompt/references/techniques.md` § Closed-World Enumeration & Invention Bans.

### K13 · Consumer sentence

- **Discriminator** — delete the sentence naming who consumes the output and what arrives, then re-read the rest: does at least one downstream instruction become ambiguous about how deep, how long, in whose voice, or what is in scope? Yes → keep. Counterfeit signature: a consumer sentence stating the ambient default, or paraphrasing the role line.
- **Pattern** — `rg -in 'you (will be given|receive)|your (findings|response|output) will be'`
- **Specimen** — Load-bearing: "You receive a unified diff; your findings will be posted to the author as PR comments." (fixes depth, tone, and that pre-existing debt is out of scope). "You are selecting memories that will be useful to ${AGENT_HARNESS} as it processes a user's query. You will be given…" (makes "relevant" decidable). Counterfeit: "You are an AI assistant that helps review code. The user will read your review."
- **Source** — `skills/craft-prompt/references/transformations.md` T1 move 2; `skills/craft-prompt/SKILL.md` §E.1.

### K14 · Null-branch blessing

- **Discriminator** — does the task have an outcome where the correct action is no artifact? Then that branch must be stated with its concrete null action. An unstated null branch is a defect, not a saving — the editor may not cut toward it. Discriminator against padding: the rule names the concrete action NOT to take, not a mood. Live probe: feed a known-clean input and check whether output is invented.
- **Pattern** — `rg -in 'do not post|say so in one line|do not manufacture|only .* if you actually'`
- **Specimen** — Load-bearing: "Only post to Slack if you actually found something stuck. If every session looks healthy, tell the user that directly — do not post an all-clear to the channel."; "If nothing meets the bar, say so in one line. Do not manufacture findings to look thorough." Counterfeit: "Be concise if there's nothing to report." — names no null action, forbids nothing.
- **Source** — `skills/craft-prompt/SKILL.md` principle 7; `skills/craft-prompt/references/transformations.md` T1 move 8.

### K15 · Numbers and thresholds

- **Discriminator** — strike every adjective and adverb from the clause and ask what remains gradeable from the output alone. A threshold a third party could grade is load-bearing: the number is the only part a grader — or the model — can apply. Removing a number to shorten a line is a behavior change requiring a regression run, not a copy edit. The cut inside this category is the adjectives around the number (→ W2).
- **Pattern** — `rg -n '[0-9]+ ?(%|x|w|lines|tokens|words)?\b' <file>`
- **Specimen** — Load-bearing: `Only flag issues you are >80% confident are real`; `keep text between tool calls to ≤25 words`; `Budget: 1–3 per major section.` Counterfeit: "Be thorough but concise"; and the pair "don't miss anything" + "mention it anyway just in case" — two unbounded pushes in the same direction with no gate between them.
- **Source** — `skills/craft-prompt/references/techniques.md` § Output formats ("Numeric length anchors over qualitative concision"); `skills/craft-prompt/SKILL.md` principle 9.

### K16 · Quoted literals

- **Discriminator** — could a downstream matcher — a parser, a grep, a permission glob, a shell, or the model's own surface-form matching — fail if one character changed? Then the string is code: never compress, never smart-quote, never re-case, never tidy. The cut inside this category is the GLOSS around the literal, never the literal.
- **Pattern** — `rg -no '`[^`]+`' <file>` and check each against a matcher.
- **Specimen** — Load-bearing: `allowed-tools: Bash(git log:*), Bash(git status:*)` rather than "Bash for git"; `NEVER say "Let me try…"`; `in parallel, in a single message`; `file_path:line_number`; `owner/repo#123`. Counterfeit: "Bash for git"; "Saying something like 'let me check' is discouraged" — nothing to match, nothing enforced; and the prose "in other words, batch them together" beside a literal that already says it.
- **Source** — `skills/craft-prompt/SKILL.md` principle 9 and §B frontmatter rules; `skills/craft-prompt/references/techniques.md` § Voice, § Closed-World Enumeration.

### K17 · Cross-context duplication

- **Discriminator** — name the reader of each unit before judging it. If the unit will be read in a context lacking the rest of the prompt — a fresh spawn, a forked subagent, a post-compaction continuation, a hook-injected reminder — the discriminator is "would the callee's decision change if this were absent?", falsifiable by spawning the callee with only its own text. Counterfeit: duplication between two units the SAME reader sees in one window with no distinct framing — worse than waste, because the copies drift into a contradiction and placement does not reliably arbitrate contradictions. When the other unit is an injected surface rather than a file — a hook preamble, a recall block, a tool result — read it and cut what it already carries, but never the two clauses it cannot carry: what to do when it does not fire, and any instruction whose only other home was that injection (since 2026-08-03 · `CLAUDE.md` § Memory — the SessionStart preamble already said "verify time-sensitive facts before asserting" and labelled every section, so restating both was freight; the verify instruction still had to be re-homed onto the hookless fallback, where nothing is injected at all).
- **Pattern** — `rg -nF '<the duplicated sentence>' ~/.claude`
- **Specimen** — Load-bearing: a read-only agent's closing `REMEMBER: You can ONLY explore and plan. You CANNOT and MUST NOT write, edit, or modify any files.` after the guidelines, for a reader whose context may have been compacted. Counterfeit: two sections of the same SKILL.md each listing the frontmatter rules.
- **Source** — `skills/craft-prompt/SKILL.md` §C and § Stress-testing test 8; code.claude.com/docs/en/skills; `rules/documentation.md` § Duplicated assertions (fetched 2026-07-29).

### K18 · Named diagnostic

- **Discriminator** — the corpus's hardest discrimination, and the one an editor gets wrong most often: a failure-mode item earns its tokens iff it adds a way to NOTICE the failure that the body never gives. The test is never "does this item repeat content". Refinement: an item dies when its inspection is already an exit-phase checklist item; it lives when it is the only exit-side copy of a body rule, or adds a recognition signal the body never states (since 2026-07-30 · gigaresearch §Failure-modes adjudication — copy-counting alone would have cut six of twelve).
- **Pattern** — per item, `rg` its key noun in the body, then ask what inspection the item prescribes.
- **Specimen** — Load-bearing: `**First-page research** — a source list one query could have produced means the loop never ran.` (adds an inspection: read the source list). Counterfeit: `**Snippet research** — citing pages never actually fetched.` (restates the checklist line "every cited page was actually fetched this run") — cut by /tighten 2026-07-30; its inspection lives in § Phase 5's checklist. The Keep, First-page research, remains in § Failure modes to avoid.
- **Source** — house corpus audit 2026-07-29 · `skills/gigaresearch/SKILL.md` § Then loop until saturation, § Phase 5 — Pre-flight check, § Failure modes to avoid.

### K19 · Provenance stamp

- **Discriminator (a) · stamp integrity** — never strip a parenthetical containing an ISO date. Its job is future-facing: it tells the next editor when the rule was last true and against what, so an obsolete rule can be retired instead of cargo-culted. Absence of the stamp beside a standing claim is the finding, not its presence. A `(verified …)` stamp must cite the PRIMARY source; a recap locates a source and never verifies it. When a CUT's rationale rests on an undated observation, date the evidence or let the observation die with the span — a cut never banks an unverifiable claim as its license (since 2026-07-30 · gigaresearch date-rule adjudication).
- **Discriminator (b) · stamp shape** — a dated-and-sourced parenthetical missing the keyword (`since`/`verified`/`measured`/`unverified`) is a REWRITE to the canonical shape — content preserved, greppability restored (since 2026-07-30 · gigarefine: a keyword-less stamp shape shared by all five giga siblings evades the house grep). Keyword selection: a claim checked against a cited source takes `verified` · a rule's origin takes `since` · a number this run derived takes `measured` (since 2026-07-30 · gigareview set the family precedent). A file that DECLARES its own stamp-shape convention (a K25-style fence) binds its own family only — normalize other files to the house shape on the corpus majority (since 2026-07-30 · craft-prompt run, 26:3). A rationale whose FACT is true but whose stated MECHANISM is false is a REWRITE to the true mechanism — or FLAG when the span is protected surface (since 2026-07-30 · gigasweep: "read-only by construction" claimed a tool-grant mechanism the grant contradicts).
- **Discriminator (c) · stamp economy** — (a) forbids deleting a stamp, never shortening one. A stamp earns the date, the keyword, and the shortest naming of the artifact a future editor would have to re-ground; the incident's mechanism, its recovery, and how it was noticed are git history. Compress to the outcome, keep every incident, drop machine-local paths per CLAUDE.md § Rules — rewrite, never cut. The always-loaded file is the one exception, because every stamp there is charged against every session: a stamp dating a change in the rule's MEANING or scope stays, since nothing else tells the next editor what the rule used to be, while one that merely evidences the founding incident goes to git history and the rule stands on its own statement. (since 2026-08-03 · `CLAUDE.md` § Tools — a 154-word ambient-cwd rule compressed to 63; its founding-incident stamp was then removed twice by the file's author, while § Operation's scope-change stamp stayed, leaving CLAUDE.md with exactly one stamp, of the meaning-change kind)
- **Pattern** — `rg -n '\((since|verified|unverified|observed|measured) [0-9]{4}-[0-9]{2}-[0-9]{2}'`
- **Specimen** — Keep: `rules/bash.md` § macOS 3.2 compatibility "**Never nest `case` inside `$( )` command substitution** — the 3.2 parser fails on the pattern's `)`… (since 2026-07-12 · monitor-github/scripts/monitor.sh)"; same section's "Every failure above re-probed against 3.2.57. (verified 2026-07-19)". Finding: "verified against current docs" with no date — inflates trust while rotting invisibly.
- **Source** — `rules/documentation.md` § Stamps, § Stale-claim custody; `rules/bash.md` § macOS 3.2 compatibility.

### K20 · Incident Why-line

- **Discriminator** — read the `Why:` line and ask whether it contains a fact absent from the rule (a mechanism, a measurement, a dated failure). Yes → it stays; it is what lets the agent decide edge cases. Merely re-asserts the rule in different words → it is rationale-that-repeats-the-rule (→ K5); cut.
- **Pattern** — `rg -n '^\s*(Why:|_Why:)' <file>`
- **Specimen** — Keep: `rules/documentation.md` "Why: every review is diff-scoped and every consistency check uses the repo as its oracle — a false claim about the outside world that predates the diff has neither reviewer nor oracle. (since 2026-07-15 · monitor-github/references/monitoring-guide.md claimed 'Claude Code has no dedicated monitor tool' for months while SKILL.md recommended that very tool.)" Also the two-word variant "Why: nothing validates markdown pointers." Counterfeit: "Why: because documentation should be accurate."
- **Source** — `rules/documentation.md` § Stale-claim custody, § Reference integrity.

### K21 · Observed-surprise caveat

- **Discriminator** — keep any clause reporting an observed surprise ("observed", "has been observed arriving", "holds no X, only Y"), especially with a date. These are the corpus's bug-report layer, and deleting one silently reintroduces a fixed failure. Ordinary hedges have no observation behind them and do not qualify.
- **Pattern** — `rg -in 'has been observed|\(observed [0-9]{4}|holds no |turned out to'`
- **Specimen** — Keep: `skills/execute-plan/SKILL.md` § Rules "Worktree isolation caveat (observed 2026-07-19): `isolation: 'worktree'` created the worktree from the WRONG git root"; `skills/gigaresearch/SKILL.md` § Web stack (this environment) "`~/.bun/bin` holds no JS runtime, only the agent-browser binary (verified 2026-07-19)"; `skills/execute-plan/SKILL.md` § 3. Execute `// args has been observed arriving JSON-encoded — parse defensively.` Counterfeit: `Note: behavior may vary` — an unbounded hedge with no observation, no date, and no probe behind it, which is what this discriminator exists to separate out.
- **Source** — house corpus audit 2026-07-29 · `skills/execute-plan/SKILL.md` § 3. Execute, § Rules; `skills/gigaresearch/SKILL.md` § Web stack (this environment).

### K22 · Per-step success criteria

- **Discriminator** — keep every success-criteria block whose content is checkable without judgment (a command, a file state, a boolean). The tell that it earns tokens: it names an artifact or probe the step's prose does not. Cut the ones that narrate the step back in the future tense.
- **Pattern** — `rg -n '\*\*Success criteria\*\*'`
- **Specimen** — Keep: `skills/execute-plan/SKILL.md` § 1. Resolve the plan "**Success criteria**: Plan loaded, target repo confirmed, drift noted (or none). If the plan names a different repo than the cwd, stop and say so." and the standard it enforces, § 2. Decompose into a workflow "per-step success criteria (machine-checkable — "tests pass", not "works")". Counterfeit: "**Success criteria**: the step is complete and correct."
- **Source** — house corpus audit 2026-07-29 · `skills/execute-plan/SKILL.md` § 1. Resolve the plan, § 2. Decompose into a workflow.

### K23 · Default-suppressing clause

- **Discriminator** — keep any statement that suppresses or mandates an interaction the agent would otherwise get wrong by default (asking permission when none is wanted, posting without being asked). Test by deleting it and asking "what would a default agent now do here?" — a different answer means it was load-bearing.
- **Pattern** — `rg -in 'human checkpoint|never pass it unprompted|do not ask|without asking'`
- **Specimen** — Keep: `skills/dissolve/SKILL.md` (historical 2026-07-30 · skill merged into end-session/delete-hard) § 3. Summary, then kill via /delete "**Human checkpoint**: none. Invoking `/dissolve` IS the go-ahead for routing and kill."; `skills/pr-review/SKILL.md` § The loop "Then offer `--post`; never pass it unprompted." Counterfeit: "Ask the user if anything is unclear."
- **Source** — house corpus audit 2026-07-29 · `skills/dissolve/SKILL.md` § 3. Summary, then kill via /delete; `skills/pr-review/SKILL.md` § The loop.

### K24 · Cited measurement

- **Discriminator** — keep every parenthetical version gate and every numeric measurement with a source. The version marker is literally the detection test for the rule; the measurement licenses bending the rule when the situation differs. A measurement with NO source and NO consequent is a value appositive instead (→ R4).
- **Pattern** — `rg -n '\([0-9]+\.[0-9]+\+\)|measured|in production ablations'`
- **Specimen** — Keep: `rules/bash.md` § macOS 3.2 compatibility "**Dispatch with parallel arrays or `case`, not associative arrays** (`declare -A`, 4.0+)"; "**Wait on a specific PID, not `wait -n`** (4.3+)"; `skills/information-architecture/SKILL.md` § Ground rules "search is 4–15% of file retrievals (Bergman et al. 2008; Fitchett & Cockburn 2015 · references/playbook.md) and better engines never changed that"; `skills/gigaresearch/SKILL.md` § Then loop until saturation "in production ablations, removing the maintained outline was the single largest quality drop".
- **Source** — house corpus audit 2026-07-29 · `rules/bash.md` § macOS 3.2 compatibility; `skills/information-architecture/SKILL.md` § Ground rules; `skills/gigaresearch/SKILL.md` § Then loop until saturation.

### K25 · Declared-mirror fence

- **Discriminator** — distinguish "this text explains why the doc looks like this" (meta-narration → R6) from "this text tells you what not to add here, and where it lives instead" (a fence). The fence names a location and an editing obligation; deleting it invites the exact duplication the house duplicated-assertions rule polices. Scope: a fence covers only the mirror it NAMES — overlaps with a third location adjudicate on their own diffs; and a fence governs the row SET unless it names order (since 2026-07-30 · information-architecture run).
- **Pattern** — `rg -in 'mirror of|a row added there|deliberately doesn.t restate|this copy is'`
- **Specimen** — Keep: `skills/information-architecture/SKILL.md` § Quick decision guide "Mirror of playbook §17 — this copy is the always-loaded router; a row added there is added here too."; `CLAUDE.md` § Memory "read those when needed; this file deliberately doesn't restate them, they change faster than it does." Counterfeit: `skills/agent-browser/SKILL.md` § Start here "The content in this stub cannot change between releases, which is why it just points at `skills get core`" — explains a decision already executed, names no future obligation.
- **Source** — house corpus audit 2026-07-29 · `skills/information-architecture/SKILL.md` § Quick decision guide; `CLAUDE.md` § Memory; `rules/documentation.md` § Duplicated assertions.

### K26 · Product-consistency instruction

- **Discriminator** — ask whose gap the instruction closes. A capability gap belongs to the model, and the null-prompt test (→ M1) decides it. A preference or predictability gap belongs to the human — output shape, tone, interaction defaults, a UX invariant — and passing the null-prompt test does NOT kill it: the model would do something reasonable, just not the same reasonable thing every time. Judge these on consistency value instead: name the user-visible variation that returns if the line goes. Counterfeit: a capability push in preference costume ("be thorough so the user trusts the output") — no shape is specified, so nothing becomes less predictable when it goes.
- **Pattern** — `rg -in 'always (report|answer|respond|format)|in one line|no emojis|use .* format|tone'`
- **Specimen** — Keep: `../SKILL.md` § 8. Report "reported and never chased" (fixes what the report contains); "Use Unicode symbols (typographic), never emojis" (a house-surface invariant no capability gap motivates); "say so in one line" (fixes the shape of the null case). Counterfeit: "Be helpful and thorough in your responses."
- **Source** — Boris Cherny, "Building Claude Code", YC Startup School 2026 — transcript at ycombinator.com/library/UN-boris-cherny-building-claude-code (verified 2026-07-29): "when you use Claude Code as a product, you do actually want some of these prompts because it helps you use the product and … helps the product behave and the model behave in the way that you would want when … you're using it as a person."
