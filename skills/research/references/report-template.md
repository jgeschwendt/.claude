# Report Structure

Use this template for `$WS/report.md`:

```markdown
# [Title — ideally the question, answered]

_Research date: [date] · Sources consulted: [N] · Depth: [standard/heavy]_

## Executive summary

The answer in under 200 words. A reader who stops here should
leave with the correct conclusion and its biggest caveat.

## Key findings

Numbered. Each finding is 2–4 sentences with inline citations [n].
Order by importance to the question, not by discovery order.

## Analysis

One subsection per sub-question from the plan. This is where
nuance, mechanisms, and context live.

## Where sources disagree

(Include only if they do.) State each side, its sources, and your
read on which is stronger and why — or say it's unresolved.

## Implications (optional — decision and forecast reports)

What follows from the findings for the reader's decision. Clearly
your inference, not a sourced fact.

## What to watch (optional — forecast and fast-moving topics)

Leading indicators that would change the conclusion, and in which
direction.

## Limitations and open questions

What couldn't be verified, what's missing from the public record,
what would change the conclusion if it turned out differently.

## Sources

[1] Title — Publisher, publication date. URL
(one-line note: source type and any credibility caveat)
[2] ...
```

Writing notes:

- Prose over bullets in the analysis sections; bullets are for the findings list.
- Fewer, broader sections beat many fine ones; cap heading depth at three levels; check sections don't overlap and jointly cover the question — over-segmentation is a measured model failure.
- Keep three registers visibly distinct: observation (what sources say), interpretation (what you make of it), implication (what follows). A reader should never wonder which one they are reading.
- Limitations should name notable negative searches ("searched A, B; found nothing") — the query log in leads.md is what makes that claim honest.
- Confidence language comes straight from `claims.md` statuses: `established` (2+ independent sources) → assert it; `reported` (one credible source) → attribute it; `contested` → present both sides; `unverified` → omit or flag explicitly. Never let report wording outrun ledger status.
- Diversity does not survive synthesis on its own — models homogenize diverse sources. Where the ledger holds `contested` or multi-viewpoint entries, name the viewpoints in the section and write to each explicitly.
- Paraphrase rather than quote. Any direct quote stays under 15 words with clear attribution.
- The sources list is part of the deliverable, not an afterthought — a reader should be able to audit any claim in under a minute.
