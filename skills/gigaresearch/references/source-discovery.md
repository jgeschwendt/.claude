# Finding Sources

Discovery is a distinct skill from evaluation. This file catalogs where information lives and the tactics for reaching it.

## Who would publish this? — the venue map

Match the information need to its producers before searching:

| You need                        | Who produces it                                    | Where it lives                                                                                      |
| ------------------------------- | -------------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| Hard numbers, statistics        | Governments, statistical agencies, industry bodies | .gov/.int sites, OECD, World Bank, Eurostat, census bureaus, trade associations                     |
| Scientific findings, mechanisms | Academics                                          | Google Scholar, PubMed, arXiv, SSRN, Semantic Scholar — review papers first                         |
| Company facts                   | The company itself; its regulators                 | IR pages, SEC EDGAR and other filing registries, annual reports, earnings call transcripts          |
| Practitioner reality            | Practitioners                                      | Reddit, Hacker News (hn.algolia.com), Stack Overflow, GitHub issues, specialist forums              |
| Disputes, wrongdoing            | Journalists, litigants, regulators, short-sellers  | Investigative outlets, CourtListener/PACER, enforcement actions, activist reports                   |
| Technical specifics             | Maintainers, standards bodies                      | Official docs, changelogs, RFCs, specs, source repositories                                         |
| Historical record               | Archives                                           | Newspaper archives, Internet Archive / Wayback Machine                                              |
| Expert judgment                 | Named experts                                      | Personal blogs, conference talks, podcast interviews, testimony                                     |
| Grey literature                 | Standards bodies, patent offices, universities     | Patents (Google Patents), standards (ISO/IETF/IEEE), theses, conference proceedings, working papers |

Interested parties are still sources — a vendor benchmark or an activist report contains real information — but log the incentive (see source-evaluation.md) and deliberately seek the opposing party's artifact too.

## Hubs: sources that point to sources

Seek these in the first pass on any sub-question:

- Survey and review papers, meta-analyses
- Wikipedia's reference sections — mine the references, cite the primaries
- Curated lists: GitHub awesome-* repos, course syllabi, published bibliographies
- Longform explainers by journalists who cover the beat

A hub's citations are pre-filtered by someone who already did discovery. Chain from them rather than starting cold.

## Citation chaining

- **Backward** (toward origins): follow a source's references. For any key number, ask "where did this come from?" and keep following until you hit the original artifact.
- **Forward** (toward the present): search the exact title in quotes; use Scholar's "cited by"; search author + topic for follow-ups and rebuttals.
- **Sideways**: search the author's other work; `site:` search the publishing org's domain; check what else the venue holds on the topic.

## Query craft

- **Broad-short first** — open with short, broad queries to map the landscape, then narrow with learned vocabulary; over-specific opening queries return few results and stall the loop. Before every search, scan the query log: re-issuing a near-duplicate of a logged query is the most common measured exploration failure — rephrase genuinely or switch venue instead.
- **Vocabulary laddering** — begin with the user's phrasing, harvest the field's jargon from the first good sources, re-search with the jargon. Most of a topic is invisible until you know its names.
- **Perspective flipping** — for any X, also search "X criticism", "X lawsuit", "X vs [alternative]", "X failure". The counter-case rarely shares vocabulary with the pro-case.
- **Entity queries** — "[person] interview", "[company] 10-K", "[report name] pdf", "[law] full text".
- **Venue targeting** — `site:reddit.com`, `site:github.com`, `filetype:pdf` for reports and papers.
- **Date scoping** — add the current year for fast-moving topics; add past years to escape recency bias in rankings.
- **Language and region** — for regional topics, search key terms in the local language and translate what comes back.

## When the well runs dry

- Reframe: who _else_ would care about this question, and what would they call it?
- Try an adjacent field's vocabulary for the same phenomenon.
- Use the venue's own search (Scholar, EDGAR, court records, forum search) instead of general web search.
- Resurrect dead links through the Wayback Machine.
- Paywalled? Read the abstract, hunt the author's preprint (personal site, institutional repository), read what citing works say — and flag secondary characterizations as such.
- If it is genuinely not findable, record that. Absence from the public record is itself a finding for the Limitations section.
