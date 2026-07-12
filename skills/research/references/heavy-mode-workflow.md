# Heavy Mode on the Workflow Tool

Dispatch waves through Claude Code's Workflow tool: schema-forced returns (no parsing subagent prose), journal-backed resume, automatic concurrency. **This skill's instruction here is the required Workflow opt-in.** If Workflow is unavailable, fall back to plain parallel subagents with the same briefs.

Division of labor is unchanged: workflows run the _legwork_; the main session stays the editor — it curates `leads.md`, keeps `claims.md`, and decides each next wave. One wave per invocation, deliberately: lead triage between waves is a judgment call, not a script.

## Script 1 — discovery wave

Pass `args` as real JSON: `{ws, context, targets: [{slug, brief}]}` — `brief` is the standard subagent brief from SKILL.md Phase 2, `context` the paragraph from `plan.md`.

```js
export const meta = {
  name: "research-wave",
  description: "One discovery wave: an agent per target, structured findings + leads back",
  phases: [{ title: "Discover" }],
};
const FINDINGS = {
  type: "object",
  required: ["file", "leads", "queries", "summary"],
  properties: {
    file: { type: "string", description: "absolute path of the findings file written" },
    leads: {
      type: "array",
      items: { type: "string" },
      description: "cited-but-unfetched sources, terms of art, people/orgs worth looking up",
    },
    queries: {
      type: "array",
      items: { type: "string" },
      description: "every query run, including duds",
    },
    summary: { type: "string", description: "5 lines max" },
  },
};
const A = typeof args === "string" ? JSON.parse(args) : args; // args can arrive JSON-encoded
phase("Discover");
const results = await parallel(
  A.targets.map(
    (t) => () =>
      agent(
        `${t.brief}

Context: ${A.context}
Load WebSearch and WebFetch via ToolSearch before starting.
Write findings to ${A.ws}/findings/${t.slug}.md — create it even if thin, and say why it is thin.`,
        { label: t.slug, schema: FINDINGS },
      ),
  ),
);
return results.filter(Boolean);
```

After each wave, in the main session: confirm each returned `file` exists and its findings carry URLs (no file, no findings — summaries alone are leads at best); merge `leads` into `leads.md` and `queries` into the query log; update `claims.md` from the findings files; pick the next wave's targets from the best unexplored leads **and `outline.md`'s thinnest sections** — leads often cut across sub-questions, and the outline steers retrieval away from covered ground.

## Script 2 — blind factored verification (Phase 3)

Draft 2–3 open-form questions per load-bearing claim, then pass `{claims: [{id, questions}]}`. The verifier prompt carries the question **only** — never the claim or its recorded evidence; blind is the point. Where fresh answers disagree with the ledger, the ledger changes.

```js
export const meta = {
  name: "research-verify",
  description: "Blind factored verification of load-bearing claims",
  phases: [{ title: "Verify" }],
};
const ANSWER = {
  type: "object",
  required: ["answer", "confidence", "sources"],
  properties: {
    answer: { type: "string" },
    confidence: { enum: ["high", "medium", "low"] },
    sources: { type: "array", items: { type: "string" }, description: "URLs actually fetched" },
  },
};
const A = typeof args === "string" ? JSON.parse(args) : args; // args can arrive JSON-encoded
phase("Verify");
const out = await parallel(
  A.claims.flatMap((c) =>
    c.questions.map(
      (q, i) => () =>
        agent(
          `Answer from fresh web evidence only — load WebSearch and WebFetch via ToolSearch first. Do not speculate; if the answer is unfindable, say so and return confidence: low.

${q}`,
          { label: `${c.id}.q${i + 1}`, schema: ANSWER },
        ).then((a) => ({ claim: c.id, question: q, ...a })),
    ),
  ),
);
return out.filter(Boolean);
```

## Mechanics

- Scripts are plain JS; `Date.now()`/`Math.random()` throw (resume safety) — stamp times in the main session.
- `args` may arrive as a JSON-encoded string rather than an object (observed 2026-07-12) — both scripts open with a defensive parse; keep it in any new script.
- Agents queue automatically past the concurrency cap; 10+ targets in one wave is fine.
- Interrupted run: relaunch with `{scriptPath, resumeFromRunId}` — completed agents return cached instantly. Before diagnosing an odd result, Read the run's `journal.jsonl` for the agents' actual returns.
- A skipped/dead agent returns `null` (already filtered) — re-dispatch its target next wave rather than losing the sub-question silently.
