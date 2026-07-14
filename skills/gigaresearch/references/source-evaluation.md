# Evaluating Sources

## Default hierarchy (adjust per domain)

1. **Primary documents** — papers, filings, legal texts, official specs, changelogs, transcripts, raw datasets
2. **Peer-reviewed work and systematic reviews**
3. **Established journalism** — named authors, editorial standards, cited sources
4. **Trade press and analyst reports** — useful, but note who commissioned them
5. **Company blogs and press releases** — authoritative about the company's own intent and announcements; unreliable for comparisons with competitors
6. **Forums, social media, personal blogs** — excellent for leads and practitioner sentiment; weak as sole support for a claim

Domain adjustments matter: for developer tooling, GitHub issues and maintainer comments function as primary sources. For breaking news, an established outlet beats a stale official page. For medicine, preprints rank far below reviews and clinical guidance.

## Quick checks for any source

- **Date** — current enough for this specific claim? Undated pages are a red flag.
- **Author** — named? Relevant expertise?
- **Incentive** — who benefits if readers believe this? Vendor comparisons, affiliate reviews, and advocacy pieces all need discounting.
- **Upstream** — does it cite its sources? Follow them. The original frequently says something narrower or different than the coverage claims.

## Red flags

- Circular sourcing: many articles that all trace to one press release or one tweet
- SEO listicle patterns: "Top 10 X in [year]" with affiliate links and no methodology
- Statistics with no stated origin or methodology
- Confident claims about fast-moving topics from pages more than a year old

## Handling numbers

Statistics need extra custody:

- **Trace to origin.** Find who measured it, when, with what definition and sample. A number whose methodology you cannot state is a rumor with digits.
- **Normalize before comparing.** Sources "disagree" on figures mostly because they define terms differently (revenue vs. bookings, users vs. MAU) or cover different periods and populations. State each figure's scope.
- **Plausibility-check magnitudes.** Back-of-envelope against known totals: if a claim implies a market larger than its parent industry, someone is wrong.
- **Verbatim repetition is a laundering marker.** The same figure word-for-word across many outlets means one origin — find it and evaluate that instead.

## Triangulation rule

Any claim that carries the report's conclusion — a key number, a causal claim, a "best/first/only" — needs two independent sources before being stated as fact. If only one exists, attribute it explicitly ("according to X...") rather than asserting it.
