> Referenced from SKILL.md. `claude-code/exemplars.md` shows finished prompts; this file shows the WORK — a mediocre draft becoming house-style with every move named. Study the moves and the restraint, not just the after-state. New transformations accrete here directly (Golden Rule) when a real Refine run teaches a move this one doesn't.

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
