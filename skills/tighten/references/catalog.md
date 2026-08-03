# /tighten test catalog

Every desk test the skill can name, with a falsifiable procedure, a `rg` pattern where the class is greppable, a specimen pair, and portable provenance. Tests NOMINATE; `../SKILL.md` § The verdict ladder adjudicates. A cut with no entry here does not happen.

70 entries here: 7 reversal · 20 block · 8 model-progression · 6 structural · 11 word-level · 7 placement · 7 unification · 4 per-edit gates; the 26 keep-list discriminators live in `keep-list.md` (split 2026-07-30, catalog at its re-attach budget). Ids are stable addresses across both files — never re-split a merged entry (R4, B15) or re-merge a split pair (K15/K16, U1/U2).

## Contents

- §Using this catalog
- **§R · Reversal — sentence**: R1 negation test · R2 dead language · R3 reassurance closer · R4 value appositive and severity flourish · R5 post-selection marketing · R6 authoring meta-narration · R7 comfort gloss on a cap
- **§B · Block ablation — section · paragraph · rule**: B1 sentence ablation · B2 terminal anti-pattern list · B3 rule spread across sections · B4 Goal-section recombination · B5 double-defined identifier · B6 per-mode duty duplication · B7 mechanism narrated thrice · B8 post-example annotation · B9 cross-file section duplication · B10 subsuming bullet pair · B11 same-side example collapse · B12 single-bullet heading · B13 intra-sentence gloss · B14 comment restating prose · B15 mark-and-count quota · B16 constraint-count cut · B17 derivable content · B18 oversized always-loaded block · B19 enumeration → principle · B20 formatting narration
- **§M · Model-progression — rule**: M1 null-prompt test · M2 compensatory scaffolding · M3 reasoning-echo instruction · M4 blanket tool default · M5 emphasis recalibration · M6 scope-quantifier restoration · M7 model stamp · M8 re-addition gate
- **§S · Structural rewrite — clause**: S1 actor-action · S2 passive with reader-actor · S3 nominalization dissolution · S4 expletive promotion · S5 positive form · S6 prohibition co-location
- **§W · Word-level — token**: W1 hedge/intensifier dial test · W2 criterion-free adjective · W3 doublet split-or-halve · W4 metadiscourse · W5 throat-clearing wind-up · W6 prepositional stack · W7 verbal false limb · W8 dying metaphor · W9 pretentious diction · W10 clutter taxonomy · W11 single-word ablation
- **§P · Placement and salience — block**: P1 edge placement · P2 short sentence carries the rule · P3 hardest-first ordering · P4 list cap · P5 bulk-data-first and no insurance duplication · P6 compaction budget · P7 alpha-sort exemption
- **§U · Term unification — artifact**: U1 one name per concept · U2 pronoun antecedent distance · U3 positional cross-reference · U4 reference-integrity re-grep · U5 reference depth and TOC · U6 single-valued options and no date-conditionals · U7 documented locate procedure vs emitted addresses
- **§G · Per-edit rejection gates**: G1 compression artifacts · G2 catalyst flattening · G3 fixture exclusion · G4 frozen surface
- **§K · Keep-list discriminators** → `keep-list.md`
- §Counter-evidence
- §Provenance caveats

## Using this catalog

- **Patterns pre-filter; the test adjudicates.** Every `rg` line over-matches by design. Exclude fixtures from every sweep — quoted spans, code fences, `<example>` bodies (→ G3).
- **Specimens**: `Cut` dies, `Keep` is the nearest span surviving the same pattern; a rewrite reads `Before` / `After`.
- **Provenance is portable**: book and author, arXiv id, vendor URL, primary transcript, or a path relative to the `~/.claude` repository root. House specimens cite path and section, re-anchored 2026-07-29.
- **A recap is a lead, never a verifier.** Every `(verified …)` stamp in this file cites the primary artifact — transcript, paper, repo, vendor page, or live probe (`rules/documentation.md` § Stale-claim custody).
- **A multi-gate entry is cited with its gate**: `U6(b)`, `P5(2)`. Specimen citations into live files anchor by section + quote, never by line number — a tighten pass over the cited file moves every line below its first cut (since 2026-07-29 · first run left four dangling `:n` pointers in this file). When a run cuts text this catalog quotes as a specimen, re-anchor the specimen as historical (`cut by /tighten <date>`) in the same pass — the quote stays; the claim that it still lives in the file goes. Re-anchoring edits tighten's own catalog and is in scope for EVERY run regardless of the target's scope (since 2026-07-30 · monitor-github run: a file-scoped run read the obligation as out of scope).
- **The K-series lives in `keep-list.md`.** K-id citations in this file resolve there, and its entries cite back into this file by the same id form.

---

## R · Reversal — sentence

Platitudes survive every word-level test — every word in "write high-quality code" pulls its weight and the sentence still says nothing. Kill them first or the later passes polish them.

### R1 · Negation test

- **Procedure** — mechanically negate the sentence: invert the imperative or flip the constraint's polarity. Would any competent author ship the negation as their real instruction? No → the sentence encodes no choice and constrains nothing; CUT. Yes → KEEP, and consider stating the rejected alternative, which is what the negation names.
- **Pattern** (pre-filter) — `rg -in 'high.quality|best practice|be (thorough|careful|helpful|accurate)|think carefully|quality is key|clean code'`
- **Specimen** — Cut: `Write high-quality, maintainable code.` Negation "write low-quality, unmaintainable code" is unshippable. Keep: `Prefer editing an existing file over creating a new one.` Negation "prefer creating a new file" is a real policy some codebases hold. Keep: `Local fixes over site-wide configuration changes.` Negation ("fix it once in shared config") is defensible, and the stated blast-radius rationale is exactly why it was rejected.
- **Source** — Roger L. Martin, _Playing to Win_ / "Is the Opposite of Your Choice Stupid on its Face?" (rogermartin.medium.com); cf. Richard Rumelt, _Good Strategy Bad Strategy_ on fluff.

### R2 · Dead language

- **Procedure** — the vendor's exclude-column classifier: any line stating a self-evident practice, or explaining what a widely-known format, tool, or concept IS rather than how THIS artifact uses it, is cut. Keep pitfalls, rationale, and conventions that differ from tool defaults.
- **Pattern** — `rg -in 'write clean code|follow best practices|use good judgment|be professional|it is important (to|that)'`
- **Specimen** — Cut (~150 tokens): `PDF (Portable Document Format) files are a common file format that contains text, images… There are many libraries available for PDF processing, but pdfplumber is recommended because it's easy to use…` → Keep (~50 tokens): `## Extract PDF text` + `Use pdfplumber for text extraction:` + the 3-line code block.
- **Source** — platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices § Concise is key; code.claude.com/docs/en/best-practices § Write an effective CLAUDE.md (include/exclude table) (both fetched 2026-07-29).

### R3 · Reassurance closer

- **Procedure** — delete the clause after the comma in an "X is Y working, not Z" shape. If the imperative before it still tells the agent what to do, the clause answered an objection no reader raised. Allow at most one per file, and only where the agent's known failure is hiding the very change the clause blesses.
- **Pattern** — `rg -n 'is the .*, not |that is .* (succeeding|working), not|, not a quota'`
- **Specimen** — Cut: "`Thought 7/8` becoming `Thought 7/12` is the protocol working, not sloppiness" — one of three deployments in one file, reduced to one by /tighten 2026-07-29. Keep (at most one): the instance that blesses a visible state change the agent would otherwise conceal — the surviving "scaffold, not a quota" line in § Calibrating depth.
- **Source** — house corpus audit 2026-07-29 · `skills/sequential-thinking/SKILL.md` § Calibrating depth (sole survivor; its two siblings cut by /tighten 2026-07-29).

### R4 · Value appositive and severity flourish

One instrument, two shapes: a sentence in a principle block that asserts the document's own worth, or escalates the principle's severity, without adding a measurement, a scope bound, or an action.

- **Procedure** — (a) a clause asserting the document's own value with no measurement, source, or consequent action attached is CUT; with a citation attached it is a cited measurement and stays (→ K24). (b) In a prose philosophy paragraph or after a bulleted definition list, delete every sentence that neither states the principle, bounds its scope, nor names an action — the aphoristic framing paragraph (tell: abstract nouns like "quality" or "integrity" paired with a passive "is set by") and the escalation flourish generalizing the principle to a larger N both fail all three.
- **Pattern** — `rg -in 'is what keeps|the .* separating|the single most|is the real |only deepens|even more so|all the more|the stakes are|is set by'`
- **Specimen** — Cut: `skills/gigaresearch/SKILL.md` § Workspace "This pipeline is what keeps the report honest" (cut by /tighten 2026-07-30) — the status→language mapping above it is the whole behavior. Cut: § Phase 5 — Pre-flight check "the production pattern separating grounded reports from fabricated ones" (cut by /tighten 2026-07-30). Cut: § Deep Research (lede) "Discovery quality is set by how well the leads queue is fed; report integrity by how honestly the claim ledger is kept." (cut by /tighten 2026-07-30) — the two bullets above it already state what each file holds. Cut: `CLAUDE.md` § Compromise "The trap only deepens as the options fan out toward N." (cut by /tighten 2026-07-30 · user-approved) Keep: `skills/gigaresearch/SKILL.md` § Then loop until saturation "in production ablations, removing the maintained outline was the single largest quality drop" — same superlative shape, but it carries a measurement and licenses a judgment. Keep from the Compromise paragraph: the principle ("Commit to A or to B") and the scope gate ("Reserve this for genuine tension").
- **Source** — house corpus audit 2026-07-29 · `skills/gigaresearch/SKILL.md` § Deep Research (lede), § Workspace, § Then loop until saturation, § Phase 5 — Pre-flight check; `CLAUDE.md` § Thinking Philosophies · Compromise.

### R5 · Post-selection marketing

- **Procedure** — ask of each bullet: could the agent act differently on it? Comparative claims about the tool's implementation cannot be acted on after the skill has already been selected. CUT; keep only capability lines the agent will invoke.
- **Pattern** — `rg -in 'not a (node|python|wrapper)|works with any|no .* dependency|blazing|native rust'`
- **Specimen** — Cut: `skills/agent-browser/SKILL.md` § Why agent-browser "Fast native Rust CLI, not a Node.js wrapper" / "Works with any AI agent (Cursor, Claude Code, Codex…)" / "Chrome/Chromium via CDP with no Playwright or Puppeteer dependency" — the whole section, in a file whose own § Start here declares itself a discovery stub. Keep: `skills/gigaresearch/SKILL.md` § Web stack (this environment) "`~/.bun/bin` holds no JS runtime, only the agent-browser binary" — same no-dependency shape, but it is a capability fact the agent acts on when it builds a PATH.
- **Source** — house corpus audit 2026-07-29 · `skills/agent-browser/SKILL.md` § Start here, § Why agent-browser.

### R6 · Authoring meta-narration

- **Procedure** — if the sentence explains why the text is shaped as it is, rather than what the reader must do or must not re-add, CUT it. Contrast K25: a fence that names a location and an editing obligation stays. Scope: skip spans inside a declared per-entry schema field whose content class IS authoring rationale (a registry's Design-consequence column) — the field declaration is the fence; R6 fires there only outside the schema (since 2026-07-30 · seq-thinking evidence.md, 35 entries would otherwise all fire). Corollary: the declaration itself is therefore K-protected — schema declarations, numbering policies, and entry-admission policies are authoring-surface fences other rules key on; a run that cut two of them breached the revert threshold when the cold audit sent them back (since 2026-07-30 · run 13, revert rate 3/15).
- **Pattern** — `rg -n 'which is why|that.s why this (file|section)|the reason this section'`
- **Specimen** — Cut: `skills/agent-browser/SKILL.md` § Start here "The content in this stub cannot change between releases, which is why it just points at `skills get core`." Keep: `CLAUDE.md` § Memory "read those when needed; this file deliberately doesn't restate them, they change faster than it does" — forbids a specific future edit and names where the content lives.
- **Source** — house corpus audit 2026-07-29 · `skills/agent-browser/SKILL.md` § Start here; `CLAUDE.md` § Memory.

### R7 · Comfort gloss on a cap

- **Procedure** — after any stated limit (first N, max N, up to N), delete a following clause of the form "effectively all/most real cases". If the next sentence names the workaround for exceeding the cap, the gloss was reassurance and arguably false. The cap's number stays (→ K15).
- **Pattern** — `rg -in 'effectively (all|most|every)|in practice this covers|more than enough for'`
- **Specimen** — Cut: `skills/monitor-github/SKILL.md` § Field glossary "Thread counts cover the first 50 threads per PR - effectively all real PRs." (cut by /tighten 2026-07-30) followed immediately by "For complete depth on one PR, the drill-down in § Follow-ups paginates." Keep: the cap itself, "the first 50 threads per PR", plus that next line's named workaround — the number is the enforceable part (→ K15) and the workaround is what the gloss was pretending to be.
- **Source** — house corpus audit 2026-07-29 · `skills/monitor-github/SKILL.md` § Field glossary.

---

## B · Block ablation — section · paragraph · rule

Duplicate sections dwarf adjectives, and constraint count is the primary metric. Spend the deletion budget here. Every whole-rule deletion takes rung 3.

### B1 · Sentence ablation

- **Procedure** — for each sentence S in block B, form B∖S and run the oracle. Empty diff → delete S. Two fast pre-checks: S paraphrases its predecessor (≥60% content-word overlap with no new noun); S states a fact the reader never acts on (no imperative, no condition, no threshold).
- **Pattern** — none; this is the unit-level ablation the heuristics predict.
- **Specimen** — Before: "Re-read the file before editing. The user may have edited it since your last read. Files can change during a session, so what you read earlier may no longer reflect the current contents." After: "Re-read before you edit — the user edits files alongside you, so your last read may be stale." (Sentence 3 restates sentence 2: 71% overlap, no new noun, no new action.)
- **Source** — William Strunk Jr. & E.B. White, _The Elements of Style_, Rule 17 ("a paragraph no unnecessary sentences"); William Zinsser, _On Writing Well_ ("Is every word doing new work?").

### B2 · Terminal anti-pattern list

- **Procedure** — for each item in a trailing "Anti-patterns" / "Failure modes to avoid" list, `rg` the body for the item's key noun. Body already states the rule AND the item adds no detection signal → CUT. This is the corpus's hardest discrimination; the test is "does this item add a way to NOTICE the failure", never "does this item repeat content" (→ K18).
- **Pattern** — `rg -n '^#+ .*(Anti-pattern|Failure mode|Pitfall)'` then grep each item's key noun.
- **Specimen** — Cut: "**Pressure response**: flipping a verdict because someone pushed back… models do this nearly half the time under a bare 'are you sure?'… Same failure, opposite costumes" (formerly in § Anti-patterns of `skills/sequential-thinking/SKILL.md`; cut by /tighten 2026-07-29, rung-3 ablated) — it duplicated § When the verdict is challenged down to the same statistic and the same clothing metaphor. Keep: `**First-page research** — a source list one query could have produced means the loop never ran.` — supplies an inspection (read the source list) the body never gives.
- **Source** — house corpus audit 2026-07-29 · `skills/sequential-thinking/SKILL.md` § When the verdict is challenged (the surviving body rule); `skills/gigaresearch/SKILL.md` § Failure modes.

### B3 · Rule spread across sections

Scope note: B3 fires at any granularity — three copies inside one 13-line block are still two too many; keep the copy at the decision point (since 2026-07-30 · gigadebug run asked). B7 likewise fires on TWO statements, not only three — the frontmatter copy is protected, so the body opener is always the cut (since 2026-07-30 · gigadebug lede).

- **Procedure** — pick the file's most-repeated imperative verb+object pair and `rg` it. Appearing in 3+ sections with no cross-reference → keep the copy nearest the decision point, replace the rest with a pointer or delete. Two copies at entry and exit is deliberate bracketing (→ K1); the third and later copies die.
- **Pattern** — `rg -o '^\s*[-*] \*\*[A-Z][a-z]+ [a-z]+' <file> | sort | uniq -c | sort -rn | head`
- **Specimen** — Cut: `skills/gigaresearch/SKILL.md` STATES log-every-query twice (§ Workspace, § Then loop until saturation); its § Phase 4 and § Phase 5 lines USE the log — a Limitations-content duty and a verification gate, not copies. Statement-counting that conflates uses with statements over-cuts (measured 2026-07-30 · gigaresearch run corrected this entry's own earlier "four times" claim). Cut: `skills/execute-plan/SKILL.md` § Hard rule: the model split closes on a fourth statement of the model split, after § Execute Plan (lede), that same section's opening, and § Rules (cut by /tighten 2026-07-30). Keep: the copy at the `agent()` call site, where the agent acts on it.
- **Source** — house corpus audit 2026-07-29 · `skills/gigaresearch/SKILL.md` § Workspace, § Then loop until saturation, § Phase 4 — Synthesize, § Phase 5 — Pre-flight check; `skills/execute-plan/SKILL.md` § Execute Plan (lede), § Hard rule: the model split, § Rules.

### B4 · Goal-section recombination

- **Procedure** — strike the `## Goal` (or `## Overview`) section and re-read. If every clause survives in the intro or in a step's success criteria, the section was a summary of adjacent text. Same test for trailing `## Rules` bullets: any bullet whose content already sits in a step's prose is a third copy.
- **Pattern** — `rg -n '^## (Goal|Overview|Summary|Purpose)$'`
- **Specimen** — Cut: `skills/execute-plan/SKILL.md` § Goal (the whole paragraph — cut by /tighten 2026-07-30) versus § 5. Report "**Success criteria**: The user can accept the work from this report alone", § Rules "Deviations get reported, never silently absorbed", and § Rules' worktree rule (already stated in § 2. Decompose into a workflow — cut by /tighten 2026-07-30).
- **Source** — house corpus audit 2026-07-29 · `skills/execute-plan/SKILL.md` § Goal, § 2. Decompose into a workflow, § 5. Report, § Rules.

### B5 · Double-defined identifier

Boundary: two DIFFERENT things sharing one name is not B5 duplication — it is a U1 collision (two names per concept, inverted). Rename one or gloss both; never merge the definitions (since 2026-07-30 · monitor-github: `ready_to_merge` is a snapshot field in one table and an event type in another).

- **Procedure** — extract every backticked identifier from each table in the file and intersect the column sets. An identifier defined in two tables is one definition too many: keep the definition where the agent acts on it, make the second row point at it.
- **Pattern** — ``rg -o '^\|[^|]*`([A-Za-z_][A-Za-z0-9_]+)`' <file> | sort | uniq -d`` (case-inclusive since 2026-07-30 · pr-review: the lower-case anchor returned 0 on a `PR_REVIEW_*` table and both B5 hits were found by reading)
- **Specimen** — Cut: `skills/monitor-github/SKILL.md` § Field glossary "| `ready_to_merge` (own PRs) | … The 'go press merge' signal |" versus § Continuous monitoring (daemon)'s event table "| `ready_to_merge` | high | … the 'go press merge' moment |" — same identifier, same catchphrase, two tables. Same for `auto_merge` (§ Field glossary vs § Triage) and `monitor_degraded`/`monitor_recovered` (§ Continuous monitoring (daemon)'s event table vs its **Degraded mode** paragraph).
- **Source** — house corpus audit 2026-07-29 · `skills/monitor-github/SKILL.md` § Field glossary, § Triage, § Continuous monitoring (daemon).

### B6 · Per-mode duty duplication

- **Procedure** — when a file has sibling sections for alternative modes (Monitor / hook / manual; light / standard / heavy), diff their prose. Any sentence appearing in 2+ with only cosmetic variance hoists above the sections or is deleted from all but one.
- **Pattern** — `rg -n '^#+ .*[Mm]ode' <file>`, then diff the sibling section bodies.
- **Specimen** — Cut one of: `skills/monitor-github/SKILL.md` § Continuous monitoring (daemon) "When events land, surface high-severity ones briefly and keep working" (**Delivery, Monitor mode**) / "When they do: briefly surface the high-severity items, then continue with the user's actual request." (**Delivery, hook mode**). One duty, two delivery-mode blocks, no cross-reference. (cut by /tighten 2026-07-30 — both copies cut, the duty hoisted to **Delivering events** above the three mode blocks.)
- **Source** — house corpus audit 2026-07-29 · `skills/monitor-github/SKILL.md` § Continuous monitoring (daemon).

### B7 · Mechanism narrated thrice

- **Procedure** — extract the mechanism nouns from frontmatter and `rg` them in the body's first 15 lines. Trigger phrases and the use/don't-use boundary are frontmatter's job; the step-by-step mechanism is the body's. A mechanism stated in `description`, `when_to_use`, and the body opener loses two copies — and the frontmatter copies are protected surface (→ K3), so the body opener is the cut.
- **Pattern** — `rg -n '^(description|when_to_use)' -A6 <file>` then grep those nouns over the body's first 20 lines.
- **Specimen** — Cut: `skills/dissolve/SKILL.md` (historical 2026-07-30 · skill merged into end-session/delete-hard) § Dissolve Session (lede) "It appends a pointer to the queue, copies the conversation into the 90-day buffer, and invokes the delete skill" — already in frontmatter `description` and `when_to_use`, in more detail. Keep: the body's step-by-step ordering and its per-step commands, which the frontmatter names but never spells out — the mechanism's steps are the body's job, its existence is the frontmatter's.
- **Source** — house corpus audit 2026-07-29 · `skills/dissolve/SKILL.md` frontmatter `description`, frontmatter `when_to_use`, § Dissolve Session (lede); platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices § Writing effective descriptions (fetched 2026-07-29).

### B8 · Post-example annotation

- **Procedure** — after a worked example, check whether the following paragraph names anything absent from the example's own labels. If every clause maps to a labelled line inside the fence, delete the paragraph — the example is the artifact.
- **Pattern** — `rg -n -A4 '^```$' <file>` at the close of each example fence; read the next paragraph.
- **Specimen** — Cut: "Note what made this work: the differential was enumerated before evidence arrived, the hypothesis carried its kill condition from birth…" (formerly beneath the diagnosis worked example in `skills/sequential-thinking/SKILL.md`; cut by /tighten 2026-07-29) — every clause was visible in Thoughts 2, 5, and 6 of the fence directly above it. Keep: an annotation naming what the example deliberately does NOT show ("this walk never revises a thought; see the revision branch above for that case") — an exclusion no label inside the fence carries.
- **Source** — house corpus audit 2026-07-29 · `skills/sequential-thinking/references/examples.md` (the diagnosis example; its trailing annotation was cut by /tighten 2026-07-29 while both examples still lived in the SKILL.md body — they were extracted to the reference file by /craft-prompt the same day).

### B9 · Cross-file section duplication

- **Procedure** — `rg` a distinctive phrase from any CLAUDE.md philosophy or § section across `skills/`. A hit in a skill that neither cites nor is cited by CLAUDE.md is undeclared duplication: cut the copy, leave a pointer. A DECLARED mirror stays (→ K25). Apply the corpus's own rule as a linter: a CLAUDE.md passage describing what a skill DOES violates CLAUDE.md's own no-restatement clause.
- **Pattern** — `rg -F '<distinctive 6-word phrase>' ~/.claude --glob '!**/*.jsonl'`
- **Specimen** — Cut: `CLAUDE.md` § Memory restating the ending skills' (`end-session`, `delete-hard`) frontmatter, against § Rules "Skills self-describe via frontmatter—never restate a skill's behavior in this file or another skill" (cut by /tighten 2026-07-30 · user-approved — the mechanism clauses went, the three duties stated nowhere else stayed). Historical, no longer live: `CLAUDE.md` § Premise Inheritance versus `skills/sequential-thinking/SKILL.md` § Premise inheritance, once "same thesis, parallel worked parentheticals". The skill's section now states a different law — epistemic status travels with a claim across every handoff — so the pair is no longer duplication (measured 2026-07-30 · both sections re-read). What survives is its "Task artifacts" bullet applying CLAUDE.md's move to one input class: use, not restatement, and accepted undeclared.
- **Source** — house corpus audit 2026-07-29 · `CLAUDE.md` § Memory, § Rules; `skills/sequential-thinking/SKILL.md` § Premise inheritance.

### B10 · Subsuming bullet pair

- **Procedure** — for each list of ≤5 rules, ask of every pair: does obeying A already satisfy B? Yes → merge. Terse rule sets offend most, because each bullet reads independently plausible.
- **Pattern** — none; pairwise read.
- **Specimen** — Keep all three, and the counter-case is this entry's own overturned nomination: `CLAUDE.md` § Communication "Assume expert-level context—skip basics." / "Skip preamble. Skip hedging. Lead with the answer or action." / "Minimize tokens in user-facing prose." read as one behavior policed thrice, but the first constrains content selection (which concepts to define), the second names two banned token classes with their positive substitute, and the third is a budget plus a code carve-out — obeying the budget produces neither of the others. Merging changes the constraint count 4 → 4 for ~3 words of 1,387, which is B16's named counterfeit (measured 2026-07-30 · pairwise subsumption read).
- **Source** — house corpus audit 2026-07-29 · `CLAUDE.md` § Communication.

### B11 · Same-side example collapse

- **Procedure** — for each set of sibling examples, name what each one rules OUT that the others do not. An example with no unique exclusion is a duplicate: collapse to one plus a note on the varying token. Two examples on the same side of a boundary are one example; replace the second confirming case with the nearest reject case (→ K6).
- **Pattern** — `rg -c '<example>' <file>`; then read each pair.
- **Specimen** — Keep all three, and the counter-case is this entry's own overturned nomination: `rules/comments.md` § Headers gives bash, rust, and typescript fences read as differing only in the line-comment token, which the language already fixes. They also differ in the `─` fill — 60 / 58 / 59 — which the language does not fix and which the rule ("80 columns total") only implies; the three prefix widths (2 / 4 / 3 cols) are every width the file's `paths:` admits. Each fence rules out a wrong fill count the others do not, and all three are K7 copy-targets, so collapsing makes the reader compute `80 − prefix − 18` by hand (measured 2026-07-30 · `wc` per line, run lengths counted).
- **Source** — house corpus audit 2026-07-29 · `rules/comments.md` § Headers.

### B12 · Single-bullet heading

- **Procedure** — count content lines per heading. A heading owning exactly one bullet earns nothing: inline the bullet under the parent. Exception: the heading has an inbound reference elsewhere, in which case it is an address (→ K10) and the cut must fix every pointer.
- **Pattern** — `rg -n '^#{2,3} ' <file>` and count lines between hits; `rg -n '§<heading>' ~/.claude` for inbound references.
- **Specimen** — Nominated and overturned: `rules/comments.md` `# Comments` → `## Headers` → one bullet, and `rules/typescript.md` § Type aliases. Both stand — total yield across the five single-bullet H2s in `rules/` is ~10 words of 1,690 (0.6%) at an unchanged constraint count, and across the six rules files the H2 level IS the organization scheme (12 H2s, 7 holding ≥2 bullets, 4 addressed by name from other files), so cutting only the unreferenced singletons leaves a taxonomy inconsistent by accident (measured 2026-07-30 · per-heading bullet count + corpus-wide inbound `rg`). Counter-case: `rules/documentation.md` § Reference integrity is one bullet cluster addressed by name from several files, so its heading is load-bearing.
- **Source** — house corpus audit 2026-07-29 · `rules/comments.md`; `rules/documentation.md`; `rules/typescript.md`.

### B13 · Intra-sentence gloss

- **Procedure** — look for `: ` or `—` followed by a re-wording of the immediately preceding word. Delete the gloss; if the reader still knows what to expect at runtime, it was redundant. Contrast K5: a gloss naming a mechanism outside the adjective's vocabulary stays.
- **Pattern** — `rg -n '(silently|quietly|implicitly) \w+[:—]'` plus a read of every em-dash appositive.
- **Specimen** — Cut: `rules/bash.md` § macOS 3.2 compatibility "these expand silently empty: no error, just a blank" — "no error, just a blank" is "silently empty" respelled. The version marker `(5.0+)` on the same line is the rule's detection test and stays (→ K24).
- **Source** — house corpus audit 2026-07-29 · `rules/bash.md` § macOS 3.2 compatibility.

### B14 · Comment restating prose

- **Procedure** — diff every `//` or `#` comment inside an embedded code block against the surrounding prose. A comment repeating a prose parenthetical verbatim is dead. A comment recording an empirical surprise the prose does not carry is load-bearing (→ K21).
- **Pattern** — `rg -n '^\s*(//|#) ' <file>` inside fences.
- **Specimen** — Cut: `skills/execute-plan/SKILL.md` § 3. Execute `// renames, mass edits, boilerplate` — restates § Hard rule: the model split (cut by /tighten 2026-07-30). Keep: the same fence's `// args has been observed arriving JSON-encoded — parse defensively.`
- **Source** — house corpus audit 2026-07-29 · `skills/execute-plan/SKILL.md` § Hard rule: the model split, § 3. Execute.

### B15 · Mark-and-count quota

One marking pass, two interchangeable instruments — a line quota or a bracket score. Marking is separated from deleting so the editor cannot rewrite its way to the number.

- **Procedure** — (1) Mark, never edit: either set N before reading ("Green 4" on a 40-line section) and mark exactly N lines' worth of expendable material, or wrap in `[…]` every word, phrase, or sentence not doing work. (2) Score: `bracketed ÷ total`; expect ≥0.3 on unrevised prose. (3) Adjudicate each mark against the oracle and restore only the marks whose removal changes behavior. Quota unmet → the unit was already dense; say so rather than fake the cut. Quota met by rewriting → a different job than the one assigned. Restoring >20% of marks → the marking bar was mis-calibrated, not the prose. Prefer marks that remove whole list items, whole examples, and whole sentences over marks that shave syllables. The mark list is the diff-review artifact.
- **Pattern** — none; the marking pass is the instrument. `wc -w <file>` before and after.
- **Specimen** — Pass: "Green 4" met by deleting two redundant examples (3 lines) and one sentence restating the section heading (1 line); constraint-diff empty. Bracket form: "[As a general rule,] re-read the file [in question] before you edit it [, since] the user [may] edit files alongside you [and] your last read may [therefore] be stale." — 10 of 30 tokens bracketed (33%), and step 3 restores only "may". Fail: nine sentences reworded to save four lines, introducing two new ambiguities.
- **Source** — John McPhee, _Draft No. 4_ (2017), chapter "Omission" — greening as Time's trim-to-fit practice (secondary accounts; the "Green 5"/"Green 9" notation is attested second-hand); William Zinsser, _On Writing Well_, Ch. 3 — the bracket exercise.

### B16 · Constraint-count cut

- **Procedure** — count constraints, not words. Model expected joint compliance as p^n and report it (at p≈0.97, ten rules ≈ 74% joint). For each rule, write the one-line check that would detect its silent absence; a rule with no such check is unenforceable prose and a deletion candidate. Falsify by measuring joint compliance at n, n−2, n−4 after deleting the least load-bearing rules — a rising curve proves the cut bought compliance on the survivors.
- **Pattern** — `rg -c '^\s*[-*] ' <file>` for a rule-count floor; then enumerate by hand.
- **Specimen** — Cut: a 20-rule prompt taken to 9 rules, with the constraint count logged before and after and joint compliance re-measured at each step. Keep: the same file with every adjective shaved and the constraint count unchanged — a word-count win that bought no compliance, which is the failure this entry exists to catch. Magnitude: ManyIFEval prompt-level accuracy, 1 → 10 instructions: Claude 3.5 Sonnet 95% → 48%; GPT-4o 94% → 21%. On StyleMBPP, 1 → 6 instructions: Claude 3.5 Sonnet 96% → 1%, while instruction-level accuracy stayed near-flat — the collapse is invisible to per-rule review.
- **Source** — arXiv:2509.21051 (Harada et al., "When Instructions Multiply"); arXiv:2507.11538 (Jaroslawicz et al., IFScale — omission-to-modification ratio 34.88:1 at 500 instructions).

### B17 · Derivable content

- **Procedure** — classify every entry against the vendor include/exclude table and delete anything in the exclude column: content derivable by reading the code, standard language conventions, detailed API docs (replace with a link), frequently-changing facts, long tutorials, file-by-file codebase descriptions, self-evident practices.
- **Pattern** — `rg -in '^#+ .*(directory (structure|layout)|dependencies|architecture overview|project structure)'`
- **Specimen** — Cut: directory layouts, dependency lists, architecture overviews. Keep: "Bash commands Claude can't guess", "Code style rules that differ from defaults", "Developer environment quirks (required env vars)".
- **Source** — code.claude.com/docs/en/best-practices § Write an effective CLAUDE.md; code.claude.com/docs/en/memory (fetched 2026-07-29).

### B18 · Oversized always-loaded block

- **Procedure** — for each block in an always-loaded surface, ask: is this needed on EVERY invocation? No → the block is a body-budget finding: FLAG it with the budget it breaks and route it (`../SKILL.md` step 6 · Adjudicate). This skill relocates nothing across files, and the finding is a routing decision for the artifact's owner, not a compression decision — the tokens would not shrink, they would move. Budgets to cite: CLAUDE.md ≤200 lines; SKILL.md body ≤500 lines and under ~5k tokens; metadata ~100 tokens. `@path` imports do NOT reduce cost — imported files load at launch, so an import-based split does not answer the finding.
- **Pattern** — `wc -l <file>`; `wc -w <file>` (≈1.3 tokens/word).
- **Specimen** — Flag: a 400-line form-filling walkthrough inside a SKILL.md whose always-needed path is 20 lines. Do not flag: the always-needed path itself, however long, and reference files, which cost zero tokens until read.
- **Source** — platform.claude.com/docs/en/agents-and-tools/agent-skills/overview § How Skills work; platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices § Progressive disclosure patterns; code.claude.com/docs/en/memory (fetched 2026-07-29).

### B19 · Enumeration → principle

- **Procedure** — find any list of ≥3 sibling prohibitions or cases sharing one underlying principle. Replace with one statement of the principle plus, at most, the strongest example. Verify the collapsed version still suppresses each enumerated behavior (rung 3, one behavior per run). A case that survives only because it was named is a tempting-trivial enumeration and stays (→ K8).
- **Pattern** — `rg -n -A6 '^#+ .*(Do not|Never|Avoid)'` and read sibling bullets for a shared principle.
- **Specimen** — Collapse: "surveying options it won't pursue" / "explaining root causes at length" / "producing heavily-structured PR descriptions" / "writing comments that narrate what the next line does" → one instruction ("Lead with the outcome…"). Keep enumerated: `Even for "hi". Even for "thanks."` — each named case has a writable excuse for exemption, so the principle alone does not suppress it (→ K8). Vendor claim: "A short brevity instruction is as effective as listing each pattern."
- **Source** — platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5 § Strong instruction following (fetched 2026-07-29).

### B20 · Formatting narration

- **Procedure** — delete the sentence and ask whether the markdown alone still conveys it. Ordered lists convey order, a heading conveys its scope, a code fence conveys "run this". Keep only where the file elsewhere uses numbered lists for unordered menus, which makes the statement a real disambiguation.
- **Pattern** — `rg -in 'in order|the steps below|as shown (below|above)|the following (list|table)'`
- **Specimen** — Cut: `skills/dissolve/SKILL.md` (historical 2026-07-30 · skill merged into end-session/delete-hard) § Dissolve Session (lede) "Run the steps **in order**." sitting immediately above `## 1.` / `## 2.` / `## 3.` Keep: "Rows ordered most-specific first; first match wins" above a routing table — numbering conveys sequence, but precedence-on-match is a rule no table shape states (→ P7).
- **Source** — house corpus audit 2026-07-29 · `skills/dissolve/SKILL.md` § Dissolve Session (lede).

---

## M · Model-progression — rule

Usually the largest cuttable mass. Rung 3 is mandatory here: the fix for stale scaffolding is deletion, and a whole-rule deletion is never desk-committed. The regime chosen at `../SKILL.md` step 0 sets the burden of proof — maintenance puts it on the cut, upgrade puts it on the text.

### M1 · Null-prompt test

- **Procedure** — for each rule, ask whether the current model already does this unprompted. Remove it and re-run the artifact's regression cases on the current model; keep only if behavior regresses. The null hypothesis is that default behavior is already correct. Instrument for a CLAUDE.md, rules file, or system-prompt target: `CLAUDE_CODE_SIMPLE=1` deletes all Claude Code system prompts including the tool prompts — the vendor's own ablation switch, "we actually use this as a sort of ablation to figure out: is the prompt useful?" A product-consistency instruction is exempt: its gap is the human's, not the model's (→ K26).
- **Pattern** — none; the rule inventory from step 0 is the worklist. `rg -in '\b(be thorough|don.t be lazy|do not stop until|verify before|keep the user (informed|updated))\b'` pre-filters the usual suspects.
- **Specimen** — Cut: "Be thorough. Do not be lazy." Keep: "For library and API details, read the live source — training data is a stale snapshot." (also M4's keeper) — the first names no action the current model omits; the second names a source the model cannot substitute for. Vendor instruction: "Skills developed for prior models are often too prescriptive for Claude Fable 5 and can degrade output quality. Review and consider removing older instructions if default performance is better." Scale datum: Claude Code shipped the current generation having deleted over 80% of its system prompt (Shihipar, claude.com/blog 2026-07-24); Cherny's own figure in the talk is "we deleted 80% of the system prompt" — "the model is actually a little bit more intelligent without these prompts." The "no measurable loss on our coding evaluations" framing is not in the transcript — it is the companion first-party claim from Shihipar's context-engineering article (verified 2026-07-29). Direction of travel in the same article: rules give way to judgment, examples to interface design, and upfront context to progressive disclosure — Thariq Shihipar, "The new rules of context engineering for Claude 5 generation models" (claude.com/blog, 2026-07-24 · verified 2026-07-29): "Give Claude rules" → "Let Claude use judgement", "Give Claude examples" → "Design interfaces", "Put it all upfront" → "Use progressive disclosure".
- **Source** — platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5 § Recommended scaffolding changes (verified 2026-07-29); Boris Cherny, "Building Claude Code", YC Startup School 2026 — transcript at ycombinator.com/library/UN-boris-cherny-building-claude-code (verified 2026-07-29); Thariq Shihipar, "The new rules of context engineering for Claude 5 generation models", claude.com/blog 2026-07-24 (verified 2026-07-29); `CLAUDE_CODE_SIMPLE` present in CLI 2.1.220 (verified 2026-07-29 · binary probe).

### M2 · Compensatory scaffolding

- **Procedure** — one procedure, three greps: flag the instruction, remove it, re-run the regression cases on the current model, keep only on a regression. The three classes share a mechanism (each compensates for a reticence the current model no longer has) and a fix (deletion), so they are one test — enumerating them separately is the defect B19 names.
- **Pattern** — thoroughness and tool aggression: `rg -in 'be thorough|don.t (be lazy|stop early)|exhaustive|leave no|if in doubt, use|use .* aggressively'` · self-verification: `rg -in 'verify (before|that you|your work)|double.check|self.check|make sure you (have|did)'` · forced progress updates: `rg -in 'after every \d+ tool calls|summarize progress|status update|keep the user (posted|informed)'`
- **Specimen** — Cut: "If in doubt, use [tool]" (vendor: now causes over-triggering) · "Before declaring done, verify your work and re-read the file" (over-verification, adding tokens and latency) · "After every 3 tool calls, summarize progress" (vendor: "try removing it"). Keep: a verification step naming a probe and its expected output ("run the failing case before and after the fix; paste both outputs") — a procedure, not a push.
- **Source** — platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices § Migration considerations, § Overthinking and excessive thoroughness, § Thinking and reasoning · Ask Claude to self-check bullet; platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-sonnet-5 § User-facing progress updates (fetched 2026-07-29).

### M3 · Reasoning-echo instruction

- **Procedure** — flag any instruction telling the model to echo, transcribe, or explain its internal reasoning as response text. Remove: on the current generation these trigger the `reasoning_extraction` refusal category, so this one is a defect regardless of the ablation outcome; rung 3 confirms the refusal disappears.
- **Pattern** — `rg -in 'show your (reasoning|thinking|work)|explain your reasoning|think out loud|narrate your|output your (chain of thought|reasoning)'`
- **Specimen** — Cut: "Explain your reasoning step by step in your response." Keep: `<thinking>` blocks inside an `<example>`, which specify a cognitive pattern rather than demanding a transcript (→ K6).
- **Source** — platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5 (verified 2026-07-29).

### M4 · Blanket tool default

- **Procedure** — replace blanket defaults with targeted instructions. A blanket default fires on every turn; the targeted version fires on the case that motivated it.
- **Pattern** — `rg -in 'always use|by default, use|prefer .* for (all|every)'`
- **Specimen** — Cut: "Always use the search tool before answering." Keep: "For library and API details, read the live source — training data is a stale snapshot." Vendor: "Replace blanket defaults with more targeted instructions."
- **Source** — platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices § Overthinking and excessive thoroughness (verified 2026-07-29).

### M5 · Emphasis recalibration

- **Procedure** — flag every ALL-CAPS emphasis token and `CRITICAL:` / `You MUST` prefix. Attempt two rewrites in order: plain imperative; then, if the rule is genuinely load-bearing, emphasis replaced by a one-clause reason. Keep emphasis only where a plain rewrite has been OBSERVED to fail on the current model; with no such observation the marker is a rung-3 candidate, never a desk verdict. Markers work by contrast (→ K11), so over budget (1–3 per major section) rank by unrecoverability and strip from the bottom, never uniformly. Never ADD emphasis to fix a rule being ignored — diagnose instead: buried mid-file, one of fifteen, phrased as a bare prohibition, or scope left implicit.
- **Pattern** — `rg -no '\b(IMPORTANT|CRITICAL|NEVER|MUST|ALWAYS)\b' <file> | wc -l` per section.
- **Specimen** — Cut: "CRITICAL: You MUST use this tool when…" → "Use this tool when…". Keep: BashTool's single `IMPORTANT: Avoid using this tool to run cat, head, tail, sed, awk, or echo commands, unless explicitly instructed…` inside an otherwise unmarked list of usage notes. Counterfeit stack: three `IMPORTANT:` bullets on three routine dimensions, replaced by one plain list in priority order — which encodes the weighting the caps were faking.
- **Source** — platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices § Tool usage; github.com/anthropics/skills `skills/skill-creator/SKILL.md` ("If you find yourself writing ALWAYS or NEVER in all caps… that's a yellow flag") (fetched 2026-07-29); arXiv:2310.11324.

### M6 · Scope-quantifier restoration

The audit's other direction: the same pass that deletes scaffolding restores scope, and this edit LENGTHENS.

- **Procedure** — for every rule, ask what its domain is and whether the domain is written down. Probe with a second instance the rule should cover but does not name. Applies to instance 1 and not instance 2 → the scope was implicit; restore it in words. Compression that strips "every", "not just", "including X" narrows behavior, so these tokens are instruction, not verbosity.
- **Pattern** — audit rules with NO `rg -n '\b(every|all|each|including|not just|any)\b'` hit; a low count in a rule list is the finding.
- **Specimen** — Before: `Pin the model on implementation subagents.` After: `Pin model explicitly on EVERY agent() call, including mechanical and review stages — agents inherit the session model by default.` Load-bearing quantifier already present: `CLAUDE.md` "any non-trivial implementation is delegated" — deleting "any" narrows the rule to the enumerated cases. Vendor: "It does not silently generalize an instruction from one item to another, and it does not infer requests you didn't make." Recall-drop case from the same page: a review harness told "only report high-severity issues" loses measured recall because the model now actually obeys the filter.
- **Source** — platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-sonnet-5 § More literal instruction following (verified 2026-07-29).

### M7 · Model stamp

- **Procedure** — every verdict from this pass carries `ablated <ISO date> · <model id>`. A verdict without a model stamp is unreproducible after the next upgrade, and the ledger cannot tell "cut as lard" from "carried by model default". A cut deferred for lack of rung-3 budget lands as `deferred: needs rung 3`, never as a silent keep.
- **Pattern** — `rg -n 'ablated \d{4}-\d{2}-\d{2}'` over the report; every M-pass cut must match.
- **Specimen** — Ledger line: `constraint 14 (re-read before edit) — carried by model default, ablated 2026-07-29 · claude-opus-5`. Counterfeit: `cut — model does this anyway` (no date, no model, unverifiable).
- **Source** — `rules/documentation.md` § Stamps (ISO dates, portable provenance); re-running on upgrade → `skills/craft-prompt/references/evals.md` § Model-upgrade protocol.

### M8 · Re-addition gate

Applies in the upgrade regime, where lines earn their way back into a surface that was deleted whole.

- **Procedure** — a deleted line returns only on repeated observation: run the product, watch where the model stumbles, and re-add the line after at least two stumbles on the SAME thing. A line re-added on prediction fails this gate and comes back out. Ablation's shape: "you delete the entire system prompt, and then you bring it back line by line to figure out what is the impact of each individual line."
- **Pattern** — none; the observation log is the instrument — one line per observed stumble, dated, with the transcript or run id.
- **Specimen** — Keep out: a rule re-added because the editor expected the model to need it. Add back: a rule re-added after two logged runs in which the model made the same architectural mistake. User-level form of the same discipline: "every six months delete your CLAUDE.md. Delete your skills."
- **Source** — Boris Cherny, "Building Claude Code", YC Startup School 2026 — transcript (verified 2026-07-29): "you don't wanna guess what's the instruction that the model needs… only when you see it repeatedly stumble on the same thing, that's when you add it back. But you don't wanna do it too early."

---

## S · Structural rewrite — clause

These change information content. Run each against the oracle individually; bulk application is where an over-eager editor does damage. An un-rewritable passive or nominalization is a missing-actor bug report, not a keeper — FLAG it, and never paper it over with a rewrite that invents an actor.

The §S and §W patterns are line-based: a construction wrapping a hard line break evades them. Patterns nominate; reading detects — a zero-hit sweep licenses "nothing found by pattern", never "nothing present" (since 2026-07-30 · execute-plan run: a passive spanning a wrap was found only by reading).

### S1 · Actor-action

- **Procedure** — for each finite form of `be`, classify: (a) copula asserting a state the reader must know → keep; (b) auxiliary of a passive whose actor is the reader → rewrite as an imperative; (c) existential → S4; (d) verb-plus-nominalization ("is dependent on", "is a requirement of") → collapse to one verb. Fail classes b–d. Target: under 2 `be`-forms per 100 words.
- **Pattern** — `rg -no '\b(is|are|was|were|be|being|been)\b' <file> | wc -l` against `wc -w`
- **Specimen** — Before (10 w): "There is a need for verification of the load-bearing premise." After (4 w): "Verify the load-bearing premise."
- **Source** — Richard A. Lanham, _Revising Prose_ — Paramedic Method's named moves ("circle the is forms", "who's kicking whom", "put the action in a simple active verb"); step numbering varies across editions, so cite the move.

### S2 · Passive with reader-actor

- **Procedure** — detect passives and ask "who does this?" Three outcomes: actor is the reader → rewrite as a bare imperative; actor is a named third party or system → make that actor the subject; actor genuinely unknown and the affected thing is the topic → keep, logged. A passive that cannot be rewritten because the actor is unknown is a missing-actor bug: FLAG it as under-specification.
- **Pattern** — `rg -n '\b(is|are|was|were|be|been|being|should be|must be|can be|will be)\s+\w+(ed|en)\b'`
- **Specimen** — Before (15 w, zero named actors): "The tests should be run and the branch should be rebased before the PR is opened." After (10 w, one actor, explicit order): "Run the tests, rebase the branch, then open the PR." Keep: "the file is created by the installer" when the installer is the topic. Bug-report case: "The tests should be run" never says whether the agent runs them or waits for CI.
- **Source** — Strunk & White, _The Elements of Style_, "Use the active voice"; George Orwell, "Politics and the English Language" (1946), rule 4.

### S3 · Nominalization dissolution

- **Procedure** — flag noun suffixes sitting within three tokens of a light verb, or after a preposition ("for the verification of…"). Restore the buried verb and name the actor. Cannot rewrite because the actor is unknown → that missing actor is the defect: FLAG. Gate: nominalizations ≥5% of total words fails the unit.
- **Pattern** — `rg -no '\b\w+(tion|sion|ment|ance|ence|ity|ness)\b' <file> | wc -l` against `wc -w`; then `rg -n '\b(make|perform|conduct|provide|achieve|undertake|give|is|are)\s+(a |an |the )?\w+(tion|sion|ment|ance|ence|ity)\b'`
- **Specimen** — Before (11 w): "Performance of a verification of the output is a requirement." After (5 w): "Verify the output before you report." — the actor and the timing appear only once the nominalizations dissolve, which is the diagnostic value: zombie nouns hide missing information, not just extra words.
- **Source** — Helen Sword, "Zombie Nouns", NYT Opinionator (2012-07-23) and the Writer's Diet 5% threshold; Joseph M. Williams, _Style: Lessons in Clarity and Grace_.

### S4 · Expletive promotion

- **Procedure** — promote the real subject into subject position and give it the verb. Commit if the rewrite is shorter and preserves meaning. Keep when the existence claim itself is the information — an asserted absence is load-bearing for a model that would otherwise go looking.
- **Pattern** — `rg -n '\b(there (is|are|was|were|will be|should be|needs? to be|exists?)|it (is|was) (\w+ )?(that|to))\b'`
- **Specimen** — Cut: "There are three checks that need to be run before the deploy." (12 w) → "Run three checks before you deploy." (6 w). Keep: `skills/monitor-github/references/review-data-guide.md` § Coverage table — "there is no `reviewThreads` field" asserts an absence. Measured on the house corpus, `there is/are` hits 147 times across 28 files and most are the keeper kind, which is why a blanket ban fails.
- **Source** — Lanham, _Revising Prose_ (the "is" habit); Williams, _Style_ — "delete meaningless words"; house specimen `skills/monitor-github/references/review-data-guide.md` § Coverage table.

### S5 · Positive form

- **Procedure** — for each negation, attempt the positive rewrite that names the action to take. Positive form exists and covers the same cases → substitute. Keep the negation only when it is a hard boundary with no positive complement, or when it names a specific attractive wrong action the model would otherwise take — in which case state BOTH (→ S6). Empirical exception: meta-constraints like "avoid contradictions" score 0.99–1.00 and need no surgery.
- **Pattern** — `rg -n '\b(do not|don.t|never|avoid|refrain from|without|fail to)\b'`
- **Specimen** — Before: "Do not use mock data." After: "Use only real data from the live API." Before: "Do not use markdown in your response." After: "Your response should be composed of smoothly flowing prose paragraphs." Both retained: "Never loosen shared eslint config to clear one case — fix it at the call site." Reported eval: a lowercase-only constraint scored 37% violations under positive phrasing versus 0% under "Do not use uppercase letters" — direction is task-dependent, so ablate rather than assume.
- **Source** — Strunk & White, "Put statements in positive form"; platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices § Control the format of responses; arXiv:2306.08189 ("Language models are not naysayers"); arXiv:2601.18554 (constraint-type asymmetry).

### S6 · Prohibition co-location

- **Procedure** — for every prohibition, check whether the correct substitute appears in the same sentence or the adjacent line. If not, the fix is co-location — the ban sits beside its substitute on the same line, not in a footnote the model reads after choosing — not deletion. Then check specificity: does the ban name the concrete substitute the model reaches for, or an abstract category? Specific stays, abstract goes.
- **Pattern** — `rg -n -B1 -A1 '\b(do not|never|avoid)\b'` and read for an adjacent substitute.
- **Specimen** — Load-bearing: `Use Edit (NOT sed/awk)`; "Try to maintain your current working directory… by using absolute paths and avoiding usage of cd. You may use cd if the User explicitly requests it." Counterfeit: a bare "do not X" with no named substitute, in a footnote read after the wrong choice was made.
- **Source** — `skills/craft-prompt/SKILL.md` principle 5; platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices § Control the format of responses (fetched 2026-07-29).

---

## W · Word-level — token

The hedge ban list lives in `skills/craft-prompt/references/techniques.md` § Voice; the intensifier list lives only in W1's pattern. Lowest yield per edit in this corpus — run these last, and stop when the first sweeps return nothing rather than lowering the bar.

### W1 · Hedge and intensifier dial test

- **Procedure** — for each hit, ask whether the word changes what the agent DOES versus the sentence without it. A hedge keeps only if it licenses a documented exception ("usually X — when Y, do Z" is actionable; "usually X" alone is not). An intensifier keeps only if the unit contains a contrasting weaker tier, making the emphasis comparative. Coupling to watch: deleting a hedge intensifies the claim, so run the oracle after — an over-cut hedge turns a default into an absolute.
- **Pattern** — `rg -in '\b(may|might|could|possibly|perhaps|generally|typically|usually|often|tend to|seem to)\b'` and `rg -in '\b(very|really|extremely|highly|absolutely|completely|totally|clearly|obviously|certainly)\b'`
- **Specimen** — Before: "It is very important that you should probably always try to make sure tests generally pass before committing." After: "Tests must pass before you commit. Exception: a commit on a WIP branch may fail, if you say so in the message." Keeper: "may" in "the user edits files alongside you, so your last read may be stale" — dropping it asserts the user always edits concurrently. Over-fire to catch: "Delete the branch only after the PR merges" — dropping "only" leaves sequencing where the original had a prohibition; revert.
- **Source** — Joseph M. Williams, _Style: Lessons in Clarity and Grace_ — "Hedges and Intensifiers".

### W2 · Criterion-free adjective

- **Procedure** — strike every adjective and adverb from the clause and ask what remains checkable from the output alone. A clause containing a threshold a third party could grade is load-bearing; a clause whose compliance you cannot decide by inspecting one output is the padding. Supply the number, or the clause dies — or SPLIT it into the checkable test it was gesturing at.
- **Pattern** — `rg -inw 'appropriate|properly|carefully|relevant|as needed|if necessary|reasonable|sufficient|adequate|concise|thorough|comprehensive'`
- **Specimen** — Cut: "Be thorough but concise." → "Keep text between tool calls to ≤25 words; keep final responses to ≤100 words unless the task requires more detail." Keep: `Only flag issues you are >80% confident are real`; `Budget: 1–3 per major section.` Counterfeit pair: "don't miss anything" + "mention it anyway just in case" — two unbounded pushes in the same direction with no gate between them. In this corpus the W2 pattern returns 15 hits across the 18 always-loaded SKILL.md files, 4 of them protected frontmatter (measured 2026-07-29 · `rg -inw` from this entry's Pattern line · `skills/*/SKILL.md`, 18 files, 32,214 words).
- **Source** — `skills/craft-prompt/references/techniques.md` § Output formats ("Numeric length anchors over qualitative concision"); § Voice.

### W3 · Doublet split-or-halve

- **Procedure** — delete one half. Meaning unchanged → it was a doublet, commit. Halves denote different criteria → SPLIT into two named criteria rather than leaving the conjunction, because a model reading "clear and concise" cannot tell whether it must satisfy one test or two and will trade them off silently. This is a legitimate lengthening edit.
- **Pattern** — `rg -in '\b(each and every|full and complete|clear and concise|first and foremost|thorough and complete|safe and secure|accurate and correct|final outcome|end result|period of time)\b'`
- **Specimen** — Before: "Each and every review must be thorough and complete, with clear and concise findings." After: "Review every changed file. Report each finding in one sentence plus a reproduction." — the doublets are replaced by the two checkable criteria they were gesturing at.
- **Source** — Williams, _Style_ — concision moves: delete doubled words, redundant modifiers, redundant categories.

### W4 · Metadiscourse

- **Procedure** — for each hit, ask whether a heading, a list marker, or the document's structure already conveys it. Yes → delete. No → the structure is the defect; add or fix the heading, then delete the sentence anyway. Routing sentences ("read `references/x.md` when Y") are not metadiscourse — they change behavior.
- **Pattern** — `rg -in 'in this (section|document|guide)|this (section|document) (describes|explains|covers)|as (you can see|noted above|mentioned earlier)|we will (now )?(discuss|cover)|it should be noted|the (purpose|goal) of this'`
- **Specimen** — Before: `## Verification` + "In this section we will discuss how you should go about verifying your changes. As noted above, verification matters." After: `## Verification` + "Run the failing case before and after the fix. Paste both outputs."
- **Source** — Williams, _Style_ — metadiscourse.

### W5 · Throat-clearing wind-up

- **Procedure** — delete every token from the start of the sentence up to and including the first comma or the first `that`-complementizer. Remainder still states the same requirement → the wind-up was dead; commit. The wind-up is worse than average filler because it occupies the block's highest-attention position with tokens that carry no constraint.
- **Pattern** — `rg -in '^\s*[-*]?\s*(it is (important|essential|critical|worth|necessary)|please note|note that|keep in mind|remember that|as (a )?(general )?rule|in order to|the (purpose|goal) of this (section|step) is)'`
- **Specimen** — Before: "It is important to note that you must pin the model explicitly on any implementation subagent." After: "Pin the model explicitly on any implementation subagent." (15 → 9 w.) House specimen: `skills/craft-prompt/references/transformations.md` § Transformation 1 · Before "IMPORTANT: Make sure to check for security vulnerabilities." → "Check for security vulnerabilities." — that line is a before-specimen inside a fixture block, excluded from sweeps and quoted here on purpose (→ G3).
- **Source** — Lanham, _Revising Prose_ — "start fast, no slow wind-ups"; Purdue OWL Paramedic Method handout; house specimen `skills/craft-prompt/references/transformations.md` § Transformation 1 · Before.

### W6 · Prepositional stack

- **Procedure** — count prepositions per predicate. Fail any clause with ≥3 consecutive prepositional phrases, or a sentence whose preposition count exceeds its finite-verb count by ≥3. Convert the first noun-of-noun stack into verb + object and re-count; pass requires a strictly lower count and an empty constraint-diff. PP stacks are where conditions get lost: a model reading "in the event of the failure of any of the checks" must resolve four nested nouns to find the trigger.
- **Pattern** — `rg -no '\b(of|in|for|to|with|by|on|at|from|as|about|through|regarding)\b' <file> | wc -l`
- **Specimen** — Before (13 w): "In the event of the failure of any of the verification checks, escalation is required." After (7 w): "If any verification check fails, escalate."
- **Source** — Lanham, _Revising Prose_ — Paramedic Method's first move ("circle the prepositions").

### W7 · Verbal false limb

- **Procedure** — try one verb. A single verb covers the same cases → substitute. No single verb exists (the phrase is genuinely periphrastic — "has the capacity to" ≠ "can" when the capacity is contingent) → keep and log why.
- **Pattern** — `rg -in '\b(make (contact|use|mention|reference) (with|of|to)|give rise to|play a (leading|major|key) (part|role) in|exhibit a tendency to|have the (ability|capacity) to|take (action|steps) to|have an (effect|impact) (on|upon))\b'`
- **Specimen** — Before (14 w): "Agents that exhibit a tendency to have an impact on shared config must take steps to flag it." After (9 w): "Agents that touch shared config must flag it."
- **Source** — Orwell, "Politics and the English Language" (1946), "Operators or verbal false limbs".

### W8 · Dying metaphor

- **Procedure** — state the literal operation the figure commands, in one clause, without the figure. Possible → replace with the literal operation; the figure was decoration. Impossible → the figure fails harder: the instruction's action is unspecified, so FLAG it, and expect the fix to LENGTHEN the text. Exempt: a figure both fresh and load-bearing, evoking something the literal statement cannot (→ G2).
- **Pattern** — `rg -in '\b(drill down|circle back|double down|deep dive|low.hanging fruit|move the needle|next level|boil the ocean|first.class citizen|source of truth|toe the line)\b'`
- **Specimen** — Before: "Drill down on the failing test and circle back with your findings." (literal operation: unspecified). After: "Read the failing test's assertion and stack trace, reproduce it locally, then report the smallest input that fails." Longer in words, shorter in ambiguity.
- **Source** — Orwell, "Politics and the English Language" (1946), "Dying metaphors" and rule 1.

### W9 · Pretentious diction

- **Procedure** — substitute against the short-word glossary (`utilize→use`, `leverage→use`, `facilitate→help`, `prior to→before`, `in the event that→if`, `a number of→some`, `the majority of→most`, `necessitate→require`, `ascertain→find out`). Denoted set of situations identical → the long word fails. Exception with force: a precise technical term is not pretentious diction — "idempotent" is not "safe", "nominalization" is not "noun". The pass condition is denotational identity, not brevity.
- **Pattern** — `rg -in '\b(utilize|leverage|facilitate|endeavor|commence|terminate|ascertain|methodology|prior to|subsequent to|in the event that|at this point in time|a number of|the majority of|necessitate|in close proximity to)\b'`
- **Specimen** — Before: "Prior to commencing the deployment, ascertain whether sufficient functionality has been demonstrated." After: "Before you deploy, check that enough of it works." Keeper: "idempotent" where "safe" would denote a larger, fuzzier set.
- **Source** — Orwell, "Politics and the English Language" (1946), rule 2 and the "Pretentious diction" catalogue.

### W10 · Clutter taxonomy

- **Procedure** — run the class list as one ripgrep pass; each hit is fail-by-default and a keeper needs a one-line logged reason. Classes: qualifiers; prepositions bolted onto verbs (keep only where the particle changes the verb's meaning — "check out" ≠ "check"); adverbs repeating their verb; adjectives stating known facts. Named keeper: `actually` survives when it marks empirical-vs-assumed rather than intensifying — "what users actually type, not org vocabulary" (since 2026-07-30 · two overturns on the same ground, sequential-thinking and information-architecture runs).
- **Pattern** — `rg -in '\b(a bit|sort of|kind of|somewhat|fairly|rather|quite|in a sense|to some (extent|degree)|more or less|basically|essentially|actually|really|simply|just)\b'` and `rg -in '\b(order|head|face|meet|start|finish|continue|check|test|print|log)\s+(up|out|off|over)\b'`
- **Specimen** — Before: "Basically, you should carefully consider whether it is really necessary to completely eliminate the existing file." After: "Consider whether to delete the existing file." (16 → 7 w.)
- **Source** — William Zinsser, _On Writing Well_, Ch. 3 "Clutter" — the bracket classes ("order up", "smile happily", "tall skyscraper", "a bit", "sort of", "in a sense").

### W11 · Single-word ablation

- **Procedure** — for each token t (skipping code identifiers, paths, flag names, and quoted strings), form U∖t and ask the oracle whether any agent action changes. Empty diff → delete. Batch for tractability over the closed-class candidates — determiners, auxiliaries, adverbs, hedges, prepositions, discourse markers — plus every adjective, where the survivors-that-shouldn't hide. This is the only genuinely exhaustive test on the list; every other entry is a heuristic pre-filter predicting which tokens fail it.
- **Pattern** — none; the ablation is the instrument.
- **Specimen** — "You should [always] make sure [that] you [first] check [whether or not] the tests [are] pass[ing]." → "Check that the tests pass." (18 → 5 w; every bracketed token ablates with an empty diff.)
- **Source** — Orwell, "Politics and the English Language" (1946), rule 3: "If it is possible to cut a word out, always cut it out."

---

## P · Placement and salience — block

Position is the one channel that costs zero tokens. A buried rule is worse than a deleted rule: it costs tokens and still is not followed. Every P-test on a frozen surface takes rung 3 or a FLAG.

### P1 · Edge placement

- **Procedure** — list every rule whose violation would be unacceptable, and assert each sits in the first or last ~15% of its unit. Fail if it sits in a middle sentence of a paragraph of ≥4 sentences, or the middle of a list of ≥8 items; promote it to an edge, a heading, or its own bullet. Falsify by moving a critical rule to the exact middle and re-running its case — unchanged compliance means the unit is short enough that position does not yet bite.
- **Pattern** — `rg -n '^\s*[-*] ' <file> | wc -l` for list length; locate each critical rule by line number against the unit's span.
- **Specimen** — Before (buried): "Agents inherit the session model by default, which matters for various reasons, and there are several considerations around cost and latency; an unpinned agent is a rule violation; teams often discuss this." After (edges): "Pin `model` explicitly on every implementation subagent. Agents inherit the session model by default — an unpinned agent is a rule violation." Magnitude: Liu et al.'s multi-document QA shows a ~30-point gap between first and worst-middle position, and GPT-3.5-Turbo with the answer mid-context scores BELOW its own closed-book performance.
- **Source** — arXiv:2307.03172 (Liu et al., "Lost in the Middle"); Strunk & White, "Place the emphatic words of a sentence at the end".

### P2 · Short sentence carries the rule

- **Procedure** — compute per-sentence word counts. Fail (monotony) if ≥4 consecutive sentences fall within ±2 words. Fail (unbroken load) if a sentence ≥30 words is not followed by one ≤8. Fail (no anchor) if the block's single most important rule is not its shortest sentence. Do not rewrite for cadence — the aesthetic claim is unverified for machine readers; what transfers is that a short standalone imperative is the most reliably extracted unit of instruction. Rule gets the short sentence, rationale gets the long one.
- **Pattern** — none; count words per sentence.
- **Specimen** — Before (one 44-word sentence): "When you're working on a task and you notice that the user has corrected you or repeated an instruction that isn't recorded anywhere, you should generally consider encoding it…" After: "Encode the correction. Put it in the artifact that would have prevented the miss — the skill's SKILL.md, the repo's .claude/, then rules/*.md. In-session compliance evaporates at session end; only the encoded rule persists."
- **Source** — Gary Provost, _100 Ways to Improve Your Writing_ (the five-words passage), with the cadence claim explicitly not transferred.

### P3 · Hardest-first ordering

- **Procedure** — rank each rule by how often the model violates it in the suite (empirical difficulty), reorder hardest → easiest, re-measure. Expect a several-point gain; no gain means the list is short enough that ordering is not binding. Do not inherit the folk answer "put it first": the direction of positional bias is model-family-dependent, so run the two-cell test on the target model (same list, critical rule first vs last).
- **Pattern** — `rg -n '^\s*[-*] \*\*' <file>` — a list in alphabetical order is the finding.
- **Specimen** — Before: a 7-constraint block ordered easy-to-hard. After: the same block ordered hard-to-easy, with the compliance delta named per model — PBIF measures ~7% swing for LLaMA3-8B-Instruct and ~5% for Qwen2.5-7B at 7 constraints from ordering alone, and ~25% for LLaMA3 variants moving from easy-to-hard to hard-to-easy. MOSAIC: Claude and Gemini models (plus Mixtral-8x-7b) show RECENCY — a compliance spike at index 19 — while Llama/Qwen/DeepSeek show primacy (§4.3). Mechanism: hard-to-easy ordering attracts the most attention onto the constraint block, and attention to a constraint correlates with compliance with it.
- **Source** — arXiv:2502.17204 ("Order Matters", Zeng et al.), github.com/meowpass/PBIF; arXiv:2601.18554 (MOSAIC).

### P4 · List cap

- **Procedure** — cap any single rule list near 10 items; split the overflow into a separately-loaded unit. Above roughly 15 constraints nearly every model drops sharply. Report joint compliance as p^n: at p≈0.97, ten rules ≈ 74%.
- **Pattern** — `rg -c '^\s*[-*] ' <file>` per section.
- **Specimen** — Cut: rules 15 through 20 of a 20-rule list, adjudicated one per rung-3 run. Keep: the ten survivors, reordered hardest-first (→ P3). MOSAIC: Claude/Gemini show "a very high compliance spike for constraints at index 19 and an abrupt compliance decrease… to rank 20."
- **Source** — arXiv:2601.18554 (Purpura et al., MOSAIC); arXiv:2509.21051; arXiv:2507.11538 (IFScale).

### P5 · Bulk-data-first, and no insurance duplication

- **Procedure** — two gates from one ablation. (1) For any unit over ~20k tokens, or any prompt embedding documents, transcripts, or schemas: assert the bulk material precedes the instructions and the actual ask is last. An ordering violation is a defect even when no tokens can be cut. (2) Before duplicating any instruction "for emphasis", require the A/B — pre-only vs post-only vs both — and ship duplication only on a measured win; the both-ends variant is not reliably better and is sometimes worse. Bracketing (→ K1) is the licensed exception, licensed by its four gates rather than by intuition.
- **Pattern** — structural for (1); `rg -n -F '<the constraint's distinctive phrase>' <file>` and count for (2).
- **Specimen** — Vendor: "Queries at the end can improve response quality by up to 30 percent in tests, especially with complex, multidocument inputs." Ceiling on the heuristic: BAMBOO's Pre-Ins / Post-Ins / Both-Ins ablation gives ChatGPT-16k MeetingPred 20.5 / 9.5 / 16.0 but ShowsSort 16k 54.5 / 55.4 / 54.6 — "optimal instruction positions vary depending on the model, dataset, and input length." Cut the second copy: a recoverable rule restated "to be safe".
- **Source** — platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices § Long context prompting (fetched 2026-07-29); arXiv:2309.13345 (BAMBOO) §4.4 Table 5.

### P6 · Compaction budget

- **Procedure** — verify every bracketed constraint and every critical rule sits inside the first 5,000 tokens of the SKILL.md. Auto-compaction re-attaches only that much of each re-attached skill, under a shared 25,000-token budget, so a trailer past that point is already dead. The correct edit is MOVING it inside the budget — within the same file. Corollary: past the compaction line, duplication direction REVERSES — of two copies straddling it, the in-budget copy is the survivor and the trailer copy is the cut, regardless of which reads as the restatement (since 2026-07-30 · craft-prompt run derived this composing P6 × K17 × K1; two B3 nominations self-overturned on it).
- **Pattern** — `wc -w <file>` (≈0.75 words/token as a rough floor) and locate the constraint's line.
- **Specimen** — Load-bearing trailer inside budget: the compaction prompt's closing `REMINDER: Do NOT call any tools… Tool calls will be rejected and you will fail the task.` Dead trailer: the same shape at line 480 of a 500-line SKILL.md.
- **Source** — code.claude.com/docs/en/skills (verified 2026-07-29).

### P7 · Alpha-sort exemption

- **Procedure** — after reordering any instruction rule list, write the exemption into the artifact: an instruction list's order encodes meaning (difficulty ranking, routing precedence, pipeline stages) and is exempt from the house alpha-sort rule. An unstated exemption is forfeited — a future pass alpha-sorts the list and randomizes a variable that measurably matters. The absence of the note beside a deliberately ordered list is the finding.
- **Pattern** — `rg -n 'order encodes meaning|exempt from alpha|ordered by|first match wins' <file>`
- **Specimen** — Load-bearing note: a routing table introduced by "First match wins — rows are ordered most-specific first"; a rule list headed "Ordered by what breaks worst when violated… exempt from house alpha-sort". Counterfeit: a rule list alpha-sorted "for consistency" with no note either way, which reads to the next editor as arbitrary and to the model as a randomized difficulty sequence.
- **Source** — `CLAUDE.md` § Rules (alpha-sort where order is arbitrary, with the order-encodes-meaning exception); arXiv:2502.17204.

---

## U · Term unification — artifact

### U1 · One name per concept

- **Procedure** — build a term-frequency map of the unit's domain nouns and cluster co-referents. Fail any concept named by two or more surface forms; unify on one term, declare it once, repeat it verbatim including capitalization. Do NOT apply the classical rule against repetition: for a model, two names for one thing is evidence of two things, and consistent repetition costs a few tokens to buy disambiguation.
- **Pattern** — `rg -o '\b[a-z]{4,}\b' <file> | sort | uniq -c | sort -rn | head -40` and inspect near-synonym clusters.
- **Specimen** — Before: "Load the skill. The capability describes its own triggers; the module is then applied." (three names, one thing). After: "Load the skill. The skill describes its own triggers, then you apply it." Vendor form: mix "field"/"box"/"element"/"control" → always "field"; mix "extract"/"pull"/"get"/"retrieve" → always "extract".
- **Source** — H.W. Fowler, _A Dictionary of Modern English Usage_ (1926), "Elegant variation" — inverted here; platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices § Use consistent terminology (verified 2026-07-29).

### U2 · Pronoun antecedent distance

The same asymmetry as U1, one grammatical layer down: a pronoun is a second name for a thing, and the reader pays to resolve it.

- **Procedure** — fail any `it`/`this`/`that`/`they`/`those` whose antecedent is more than one clause away, and repeat the noun instead. Falsify by handing the sentence alone to a fresh reader and asking what the pronoun refers to; a wrong or hesitant answer is the finding.
- **Pattern** — `rg -nw 'it|this|that|they|those' <file>`, reading backwards for the antecedent.
- **Specimen** — Before: "Run the linter and the formatter, then commit it." After: "…then commit the formatted files." Keep: "the user edits files alongside you, so your last read may be stale" — "your last read" is named, not pronominalized.
- **Source** — H.W. Fowler, _A Dictionary of Modern English Usage_ (1926), "Elegant variation" — inverted here; Google developer documentation style guide, "Use the same term consistently" (unverified 2026-07-29 · phrase not locatable on developers.google.com/style).

### U3 · Positional cross-reference

- **Procedure** — replace each positional reference with the referent's name or a stable id. Falsify by asking the model to act on the pointer alone: if it cannot resolve which text you meant, the reference was decorative. After any reordering edit, re-check that every surviving pointer is still correct — a wrong pointer carries a large penalty.
- **Pattern** — `rg -in '\b(the section (above|below)|as mentioned (earlier|above)|the (former|latter)|the (previous|following) section|the (first|second|third) rule)\b'`
- **Specimen** — Before: "follow the rule above" After: "follow § Scope quantifiers". Keep: "see `rules/documentation.md` § Reference integrity" — a named anchor, not a position. Attention Instruction: relative-position directives ("beginning", "midsection", "tail") produced minimal effect — "language models do not have relative position awareness" — while explicit indices or position LABELS gave 4–10% gains, with ~25% drop when the index mismatched the gold document.
- **Source** — arXiv:2406.17095 (Zhang, Meng, Collier, "Attention Instruction").

### U4 · Reference-integrity re-grep

- **Procedure** — a rename, move, or delete is not done while a resolving reference remains. `rg` the old name (word-bounded, path-scoped for common words) and fix every hit that RESOLVES — links, `paths:` frontmatter globs, procedure steps, mermaid node labels, instructing code fences. Historical prose describing the old name stays. Relative links resolve from the linking file's directory, so moving a doc shifts every `](./x)` both inside it and pointing at it.
- **Pattern** — `rg -nw '<old name>' ~/.claude`
- **Specimen** — Before: `see § Learn` still sitting in `skills/dissolve/SKILL.md` (historical 2026-07-30 · skill merged into end-session/delete-hard) after the heading it addressed was renamed. After: the heading's current name, located by `rg -nw 'learn-code' ~/.claude` and fixed in the same pass. Incident: deleting `rules/learn-code.md` left dangling references in `skills/dissolve/SKILL.md`, a mermaid diagram, and a CLAUDE.md pointer — found only by `rg`, flagged by nothing.
- **Source** — `rules/documentation.md` § Reference integrity (since 2026-07-19).

### U5 · Reference depth and TOC

- **Procedure** — build the link graph from SKILL.md. Any path of length ≥2 is a defect, and so is any reference file over 100 lines with no contents list at the top — partial reads are expected, and the TOC is what survives a `head`-style preview. Adding the TOC is an in-scope edit; re-parenting a file is structural, so that half of the finding is FLAGged and routed.
- **Pattern** — `rg -o '\]\(([^)]+\.md)\)' <file>` per level; `wc -l` each reference file.
- **Specimen** — Bad: `SKILL.md → advanced.md → details.md → (actual information)`. Good: SKILL.md lists all three as siblings. TOC shape: `# API Reference` / `## Contents` / `- Authentication and setup` / `- Core methods…`.
- **Source** — platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices § Avoid deeply nested references, § Structure longer reference files with table of contents — the 100-line TOC threshold is this page's alone (fetched 2026-07-29); github.com/anthropics/skills `skills/skill-creator/SKILL.md` states a looser >300-line variant.

### U6 · Single-valued options and no date-conditionals

- **Procedure** — (a) any list of alternative tools or approaches without a stated default is a defect: collapse to one default plus at most one escape hatch. (b) Any date-conditional instruction is a defect: restate as current behavior and demote the superseded behavior into a collapsed "Old patterns" section. (c) Examples must be concrete, not abstract.
- **Pattern** — `rg -in '\b(or you (can|could)|alternatively|either .* or .* or)\b'` and `rg -in '\b(before|after|as of) (january|february|march|april|may|june|july|august|september|october|november|december|20\d\d)\b'`
- **Specimen** — Bad: "You can use pypdf, or pdfplumber, or PyMuPDF, or pdf2image, or…" Good: "Use pdfplumber for text extraction… For scanned PDFs requiring OCR, use pdf2image with pytesseract instead." Bad: "If you're doing this before August 2025, use the old API." Good: a `## Current method` section plus a `<details>`-wrapped `## Old patterns`.
- **Source** — platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices § Avoid offering too many options, § Avoid time-sensitive information (fetched 2026-07-29).

### U7 · Documented locate procedure vs the artifact's own addresses

- **Procedure** — when a file documents a command or pattern for finding its (or a sibling's) sections, run it against EVERY address class the artifact emits — top-level, subsection, table-cell references. A procedure that fails on addresses the artifact itself produces is a defect verified by its own probe; the probe is the rung-3 evidence, and the fix appends the missing address form, byte-preserving the existing literal (K16).
- **Pattern** — no grep finds this; execute the documented command per emitted address class.
- **Specimen** — Cut/fix: information-architecture's `rg -n '^## §14.3'` → 0 hits (subsection headings carry no `§`; the table emits eight such addresses) — fixed by appending the subsection form (since 2026-07-30 · information-architecture run, probe-adjudicated).
- **Source** — first-principles, from the U3 falsification probe generalized; rules/documentation.md § Reference integrity.

---

## G · Per-edit rejection gates

These run on every candidate rewrite, before the oracle. A rewrite failing a gate is rejected, not adjudicated.

Line width and wrapping are the auto-formatter's domain (CLAUDE.md § Rules: assume auto-formatting) — never a tighten verdict, never a §G rejection (since 2026-07-30 · gigasweep run asked; run-5 stamp reflows were the same question).

### G1 · Compression artifacts

- **Procedure** — reject any rewrite introducing a sentence fragment, a new abbreviation, an arrow chain, or jargon absent from the target. These are the four artifacts the house voice fingerprint bans, and a density editor is the agent most likely to produce them.
- **Pattern** — diff-scoped: `rg -n '^\s*[-*] [a-z]'` for fragments; check every new `→`, `&`, and acronym against the original.
- **Specimen** — Reject: "Contract → ledger; ablate ≥1 rung; RC's stamped." Accept: "Enumerate the contract, then ablate one rule per run and stamp each verdict."
- **Source** — `skills/craft-prompt/references/techniques.md` § Output formats (the four compression artifacts, quoted from the live 2.1.207 system prompt).

### G2 · Catalyst flattening

- **Procedure** — for each rewrite, ask whether the original used metaphor or stated a stance rather than a procedure. Yes → it is a deliberate catalyst and the rewrite is rejected; the metaphor is the instruction. Non-metaphorical vagueness ("be careful") still gets flattened by R1.
- **Pattern** — none; read the original's register.
- **Specimen** — Reject the flattening of "the journey inward is discovery, the journey outward is redesign" into "scaffold, then revisit" — the figure carries the ordering claim the flattened form drops. Flatten freely: "be careful with shared config."
- **Source** — `skills/craft-prompt/references/techniques.md` (catalyst pattern, reject-on-sight anti-pattern list).

### G3 · Fixture exclusion

- **Procedure** — exclude fenced blocks, `<example>` bodies, and quoted before-specimens from every sweep. Deliberate bad prose is a test fixture; an automated pass will "fix" it and destroy the artifact it was demonstrating. This catalog is itself such a file.
- **Pattern** — `rg -n '^```|^<example>|^> '` to map exclusion spans before sweeping.
- **Specimen** — Protected: `skills/craft-prompt/references/transformations.md` § Transformation 1 · Before "IMPORTANT: Make sure to check for security vulnerabilities." — a before-specimen, cited as such by W5, and a hit on the very pattern that names it. Editable counterpart: the same marker on a live rule outside every fence, which is an ordinary M5 candidate.
- **Source** — house corpus audit 2026-07-29 · `skills/craft-prompt/references/transformations.md` § Transformation 1 · Before.

### G4 · Frozen surface

- **Procedure** — existing emphasis markers, sigils, Unicode conventions, delimiter style, and tag names are frozen. Edits there run rung 3 or get flagged in the report; never desk-cut. Surface-form perturbations move accuracy enormously and in a direction you cannot reason out. Frozen tag names are parser-relevant surfaces (XML tags, verdict literals, schema keys); house bold labels like `**Success criteria**` are prose, protected by their own keep-list rows instead (since 2026-07-30 · execute-plan run).
- **Pattern** — `rg -no '[✻→·—]|\b[A-Z]{3,}\b' <file>`
- **Specimen** — Reject: re-casing `IMPORTANT:` to `Important:`. Accept: leaving the marker byte-identical and routing it to M5, where the demotion is adjudicated. Magnitude: FormatSpread finds performance differences up to 76 accuracy points across semantically equivalent formatting (separators, casing, spacing) on LLaMA-2-13B, and recommends reporting a range across plausible formats rather than any single one.
- **Source** — arXiv:2310.11324 (Sclar et al., "Quantifying Language Models' Sensitivity to Spurious Features in Prompt Design").

---

## Counter-evidence

Hold these against every keep verdict in §K.

- **Structural folklore is not evidence.** A factorial study over 1,650 Claude Code CLI sessions and 16,050 function-level observations found no detectable adherence contrast from file size, instruction position, file architecture, or contradictions in adjacent files, for a trivial target annotation — size and conflict nulls carry affirmative-null Bayes factors (BF10 0.05–0.10). Justify a keep by the ablation probe the entry names, never by structure alone (arXiv:2605.10039, McMillan, "Instruction Adherence in Coding Agent Configuration Files").
- **Late-session decay is real, and more prose does not fix it.** The largest measured effect in that study was within-session: ~5.6% lower odds of compliance per additional generated function (OR = 0.944). Re-injection is the mechanism — hooks, throttled reminders, re-invocation after compaction — which is why K1 and K17 turn on placement and reachability rather than volume.
- **Compression of instruction prose specifically is unmeasured.** Every compression result cited here (the LLMLingua family, gist tokens) compresses task context or documents, not rule sets — the transfer is inference, not evidence, which is why the oracle rather than a ratio is the accept criterion (arXiv:2310.06839 · arXiv:2403.12968 · arXiv:2304.08467).

## Provenance caveats

- **Verified by fetch or probe**: Orwell's six rules; Strunk & White Rule 17; Zinsser's bracket exercise and clutter classes; Provost's five-words passage; Sword's "Zombie Nouns" and the Writer's Diet 5% threshold; Martin's "opposite is stupid on its face"; every arXiv id and abstract cited (arXiv API, 2026-07-29); the vendor pages cited by URL (fetched 2026-07-29); `CLAUDE_CODE_SIMPLE` in CLI 2.1.220 (binary probe, 2026-07-29); the Cherny talk (transcript at ycombinator.com/library/UN-boris-cherny-building-claude-code, 2026-07-29). Body-level figures in B16, P1, P3, P5 and S5 were taken from the papers at research time and not re-derived on 2026-07-29.
- **Secondary-source only — flag if precision matters**: Lanham's Paramedic Method step list varies across editions, and the lard-factor formula appears both as a percentage reduction and as a ratio, so cite the named move rather than a step number. McPhee's "Green 5"/"Green 9" notation comes from accounts of _Draft No. 4_'s "Omission" chapter rather than the book. Williams's concision categories are attested but chapter numbering shifts across editions of _Style_ — cite the book and the named move.
- **Two first-party sources, two different claims about the same deletion.** The Cherny transcript's claim is "the model is actually a little bit more intelligent without these prompts"; the "no measurable loss on our coding evaluations" framing is Anthropic's own, from Thariq Shihipar, "The new rules of context engineering for Claude 5 generation models" (claude.com/blog, 2026-07-24 · verified 2026-07-29). Cite whichever claim you are making to its own source; press recaps that blend them verify neither.
- **Where new tests go**: a density move this catalog lacks, that belongs to how a prompt is WRITTEN, encodes into `skills/craft-prompt/references/techniques.md` instead (Golden Rule, net-zero — an overlap with an existing entry merges into that entry rather than adding one).
