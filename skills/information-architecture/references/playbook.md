# The Information Architecture Playbook

### A corpus of structures, schemes, and models for designing systems

_A reference to pick from — not a methodology to follow. Each entry is a structure you can reach for, with its shape, when it fits, where it breaks, and where it transfers into software/data/systems design._

---

## How to use this playbook

The discipline splits into a few kinds of decisions. When you're designing any information environment — a site, an app, a taxonomy, a knowledge base, a service architecture, an AI tool's memory — you're really making choices on these axes:

1. **By what principle do I group things?** → _Organization schemes_ (§2)
2. **What overall shape does the grouping take?** → _Organization structures_ (§3)
3. **How rigorously do I control the categories?** → _Classification & taxonomy systems_ (§4)
4. **What do I call things?** → _Labeling systems_ (§5)
5. **How do people move through it?** → _Navigation systems_ (§6)
6. **How do people find a specific thing?** → _Search & findability_ (§7)
7. **How is the content itself shaped?** → _Content modeling_ (§8)
8. **What constrains all of this?** → _Cognitive & perceptual laws_ (§9)
9. **What principles keep me honest?** → _Design heuristics_ (§10)
10. **How do I validate it?** → _Research methods_ (§11)

Sections 12–13 cover personal/networked knowledge structures and the bridges into software and enterprise architecture. Sections 14–16 apply the discipline to concrete substrates, grounded in standards and measured studies: **file systems & directories** (§14), **datasets & research data** (§15), **data at analytics scale** (§16). Section 17 is a quick decision guide. Section 18 is the canon.

---

## §1 — Foundational frames (the mental models for IA itself)

These aren't structures you build _with_; they're lenses for thinking about the whole problem.

### The Three Circles — Rosenfeld, Morville & Arango

The "polar bear book" frames every IA decision as the intersection of:

- **Context** — business goals, politics, culture, resources, constraints
- **Content** — what you have: volume, format, structure, ownership, rate of change ("content" includes its metadata and lifecycle)
- **Users** — needs, behaviors, vocabulary, information-seeking habits

Good IA is whatever survives the tension between all three. The same book defines IA as four interlocking systems: **organization, labeling, navigation, and search** — the backbone of §§3–7 below.

### The Five Planes — Jesse James Garrett (_The Elements of User Experience_)

A stack from abstract to concrete; IA sits in the middle:

1. **Strategy** — user needs + product objectives
2. **Scope** — functional specs + content requirements
3. **Structure** — _interaction design + information architecture_ ← you are here
4. **Skeleton** — interface, navigation, information design (layout)
5. **Surface** — visual/sensory design

The value of the model: it forces you to resolve lower planes before upper ones. Choosing a nav pattern (skeleton) before settling the structure produces churn.

### Ontology / Taxonomy / Choreography — Abby Covert (_How to Make Sense of Any Mess_)

A modern, deceptively simple triad for _any_ mess:

- **Ontology** — what we _mean_ (definitions, language, the meaning of each thing)
- **Taxonomy** — how we _arrange the parts_ (the structure)
- **Choreography** — how it _changes over time_ (flows, interactions, rules of behavior)

Covert's core line: _"Information architecture is the way we arrange the parts to make sense of the whole."_ The ontology-first insistence (agree on meaning before structure) is the most-skipped, highest-leverage step in practice.

### The UX Honeycomb — Peter Morville

Seven facets of value, useful as a checklist for _findability in context_:
**Useful · Usable · Desirable · Findable · Accessible · Credible · Valuable.**
IA disproportionately owns _findable_ and _accessible_, and underwrites _useful_ and _valuable_.

### Ranganathan's Five Laws (library science, 1931 — still load-bearing)

1. Books are for use. 2. Every reader his/her book. 3. Every book its reader. 4. **Save the time of the reader.** 5. The collection is a growing organism.
   Restated for systems: optimize for access not storage; serve every user segment; ensure every item is reachable; minimize time-to-answer; design for growth. Law 4 and Law 5 are the two most violated in real systems.

---

## §2 — Organization schemes (the _principle_ of grouping)

The single most important early decision: **by what attribute do you group?** Schemes divide into **exact** (objective, unambiguous, no judgment needed) and **ambiguous** (subjective, interpretive — and almost always more useful to users).

### LATCH / The Five Hat Racks — Richard Saul Wurman

Wurman's claim: there are only five ways to organize _anything_. (Provenance, verified against the digitized 1989 text: _Information Anxiety_ lists category, time, location, alphabet, **continuum** — magnitude, best-to-worst. The LATCH acronym with Continuum relabeled "Hierarchy" first appears in _Information Architects_, 1996. Cite the edition you mean.)

| Scheme        | Group by                | Best for                                        | Failure mode                                   |
| ------------- | ----------------------- | ----------------------------------------------- | ---------------------------------------------- |
| **L**ocation  | place/geography/spatial | physical/spatial data, stores, maps, body parts | meaningless when location is irrelevant        |
| **A**lphabet  | name                    | large reference sets where users know the term  | useless when users don't know the name         |
| **T**ime      | chronology/sequence     | history, process, news, logs, events            | hides relationships across time                |
| **C**ategory  | kind/similarity         | most content, products, topics                  | category boundaries are subjective & contested |
| **H**ierarchy | magnitude/rank          | comparison by size/importance/cost              | implies an ordering users may reject           |

Mnemonic for designers: most digital problems collapse to **Category** + **Time**, with Alphabet/Location/Hierarchy as secondary sort orders. Offering _multiple_ of these on the same content (sort + filter) is the faceted approach (§4).

### Exact schemes

- **Alphabetical** — directories, indexes, glossaries. Great fallback sort, poor primary navigation.
- **Chronological** — feeds, version histories, press, logs, audit trails.
- **Geographical** — store locators, regional content, anything spatial.

### Ambiguous (subjective) schemes — the hard, valuable ones

- **Topical** — by subject. The default for content sites; only as good as your topic boundaries.
- **Task-oriented** — by what the user is trying to _do_ (verbs: "file a claim", "deploy a build"). Strong for apps and tools.
- **Audience-based** — by who the user is ("for developers / for admins / for patients"). Powerful when audiences are distinct and self-identifying; brittle when users span audiences or don't self-identify.
- **Metaphor-driven** — borrows structure from a familiar domain (desktop, cart, trash, workspace). Aids learnability; dangerous when the metaphor leaks or constrains.
- **Hybrid** — mixing schemes in one menu. Usually a smell (it breaks users' mental model), but deliberate hybrids (e.g., topical primary + task-oriented utility nav) are fine when the layers are visibly separate.

> **Rule of thumb:** pick _one_ dominant scheme per navigation level. Mixing "by topic" and "by audience" in the same list is the most common IA defect.

---

## §3 — Organization structures (the _shape_ of the grouping)

Once you've chosen a scheme, it takes a shape. These are the master structures. Almost every information system is one of these or a composite.

### 3.1 Hierarchy / Tree (top-down)

Parent→child containment. The dominant structure of the web, file systems, org charts, taxonomies, DOM trees, and most navigation.

- **Use when:** content has natural levels of generality; users browse from general to specific.
- **Tradeoffs:** breadth-vs-depth tension. **Broad & shallow** (many top-level, few levels) reduces clicks but raises choice load; **narrow & deep** lowers choice load but buries content and raises abandonment. Target the classic ~"7±2 is a myth, but keep levels shallow" — most large sites work best at 3–4 levels deep with generous breadth.
- **Variants:** strict hierarchy (one parent each) vs **polyhierarchy** (item has multiple parents — see §4).
- **Transfers to:** DOM, component trees, file systems, DNS, org design, nested config, JSON.

### 3.2 Sequence / Linear

One ordered path: step 1→2→3. Wizards, onboarding, checkout, courses, tutorials, narratives.

- **Use when:** order is mandatory or strongly recommended; you want to reduce decisions.
- **Tradeoffs:** controlling but rigid; punishes non-linear users. Add escape hatches and progress indicators.
- **Transfers to:** pipelines, state machines, ETL stages, build steps, CI/CD.

### 3.3 Matrix (multi-dimensional)

Content organized along ≥2 axes simultaneously; the user picks which dimension drives. A product comparison sortable by price _or_ rating _or_ date.

- **Use when:** users disagree about which attribute matters; multiple equally-valid sort/filter dimensions exist.
- **Tradeoffs:** cognitively heavier; needs strong UI affordances. Often realized as faceted navigation.
- **Transfers to:** OLAP cubes, pivot tables, multi-index databases, tag systems.

### 3.4 Hypertext / Network / Web (associative)

Nodes connected by non-hierarchical links; no canonical path. Wikipedia, knowledge graphs, "related articles," bidirectional-link note systems.

- **Lineage:** Vannevar Bush's _Memex_ (1945, "As We May Think" — associative trails), Ted Nelson's hypertext/transclusion. The intellectual root of the web.
- **Use when:** relationships are many-to-many and exploration/serendipity matters more than a fixed path.
- **Tradeoffs:** easy to get lost ("hypertext disorientation"); weak sense of place; hard to guarantee coverage. Usually layered _on top of_ a hierarchy, not instead of it.
- **Transfers to:** graph databases, knowledge graphs, RAG retrieval over linked docs, dependency graphs, recommendation systems.

### 3.5 Faceted / Faceted Classification

Items described by independent attribute sets ("facets"); users compose a path by selecting values across facets (color _and_ size _and_ brand). The dominant structure of modern ecommerce and search.

- **Use when:** items have multiple orthogonal attributes and users arrive with different priorities. The single most flexible structure for large, heterogeneous collections.
- **Tradeoffs:** requires clean, consistently-tagged metadata; dead-end states ("0 results"); facet explosion. The payoff is enormous; the metadata discipline cost is real.
- **Transfers to:** search filters, query builders, tag-based systems, multi-dimensional APIs. (Deep treatment in §4.)

### 3.6 Hub-and-spoke

A central index/home from which users branch out and return. Common in apps with distinct task areas.

- **Use when:** discrete tasks share a common launch point; mobile apps; dashboards.
- **Tradeoffs:** forces returns to the hub; weak for cross-task flows. Mitigate with cross-links between spokes.

### 3.7 Database / Bottom-up (metadata-first)

No predetermined structure; every item is a record with attributes, and _views_ are generated on demand from the metadata. Structure emerges from the data model rather than a hand-built tree.

- **Use when:** content is large, uniform, and frequently re-sorted; you want to defer/avoid committing to one hierarchy.
- **Tradeoffs:** only as good as the schema and tagging; weak for browsing without a generated view.
- **Transfers to:** literally the relational/document database model; headless CMS; Notion-style databases; this is where IA and data modeling merge.

> **Composites are normal.** Real systems layer these: a hierarchical backbone (3.1) for browsing, faceted filters (3.5) for large sets, hypertext links (3.4) for relationships, and a database model (3.7) underneath generating it all. The skill is choosing the _dominant_ structure and layering the rest deliberately.

---

## §4 — Classification & taxonomy systems (controlling the categories)

This is where library/information science gives software people superpowers. The question: how rigorously are your categories defined and governed?

### Spectrum of control

|                   | Controlled vocabulary | Taxonomy               | Thesaurus             | Ontology                            | Folksonomy                  |
| ----------------- | --------------------- | ---------------------- | --------------------- | ----------------------------------- | --------------------------- |
| **What**          | approved term list    | hierarchical term list | terms + relationships | terms + relationships + rules/logic | user tags, uncontrolled     |
| **Relationships** | none (just synonyms)  | broader/narrower       | BT/NT/RT + synonyms   | any typed relationship + inference  | emergent, implicit          |
| **Cost**          | low                   | medium                 | high                  | very high                           | ~zero                       |
| **Best for**      | consistency, dedup    | browsing structure     | rich findability      | reasoning, knowledge graphs         | scale, discovery, long tail |

### Controlled vocabularies & their building blocks

- **Synonym ring / equivalence set** — maps variants to one preferred term ("car / auto / automobile" → _car_). The cheapest, highest-ROI findability tool; powers query expansion.
- **Authority file** — the canonical list of allowed values for a field (countries, product lines, author names). Prevents the "USA / U.S.A. / United States" mess.
- **Thesaurus relationships (ANSI/NISO):** **BT** (broader term), **NT** (narrower term), **RT** (related term), **USE / UF** (use / used-for, for synonyms). These four relationships underlie most enterprise taxonomies and **SKOS** (the W3C standard for publishing them on the web).

### Faceted classification (the masterclass structure) — S.R. Ranganathan

Instead of one rigid tree, describe each item by _facets_ and let users combine them. Ranganathan's **Colon Classification** posited five fundamental facet categories — **PMEST**:

- **P**ersonality (the main subject/essence)
- **M**atter (material/substance)
- **E**nergy (action/process/operation)
- **S**pace (place)
- **T**ime (when)

The genius: enumerative classification (pre-listing every possible category, like Dewey) can't anticipate every combination; faceted classification _composes_ categories on demand. This is the conceptual ancestor of every ecommerce filter, tag system, and multi-dimensional query you'll ever build.

- **Enumerative vs faceted:** enumerative = exhaustive predefined list (rigid, complete, brittle). Faceted = orthogonal attributes combined at runtime (flexible, scalable, requires clean metadata). Modern systems are overwhelmingly faceted.

### Polyhierarchy

An item legitimately belongs in multiple parents (a tomato under _fruit_ and _cooking ingredient_). Supports **multiple classification** (let users find things by more than one path).

- **Use when:** rigid single-parent trees force false choices.
- **Watch for:** navigation confusion ("where am I?"), breadcrumb ambiguity, and maintenance cost. Faceting is often a cleaner solution than deep polyhierarchy.

### Ontologies & knowledge graphs

Beyond taxonomy: typed entities + typed relationships + logical rules, enabling **inference** (if A is-a B and B has-property P, A has P).

- **Stack:** RDF (subject–predicate–object triples) → RDFS/OWL (schema + logic) → SKOS (lightweight taxonomies) → SPARQL (query).
- **Use when:** you need machine reasoning, data integration across sources, or rich semantic retrieval (increasingly: grounding for LLM/RAG systems).
- **Transfers to:** knowledge graphs, semantic search, RAG context construction, graph databases.

### Folksonomies & tagging

User-generated, uncontrolled tags. Scales infinitely, captures the long tail and emergent vocabulary, costs nothing to maintain — but is noisy, inconsistent, and weak for guaranteed coverage. Best as a _complement_ to a controlled spine, not a replacement. (Tag normalization + synonym rings recover much of the loss.)

### Exemplar systems worth studying

Dewey Decimal & Library of Congress Classification (enumerative giants), the IPTC/Schema.org vocabularies (web metadata), MeSH (medical), and SNOMED CT (clinical ontology) — each a master class in a different control/scale tradeoff.

---

## §5 — Labeling systems (what you call things)

Labels are where IA meets language. A perfect structure with bad labels is unusable.

- **Label types:** contextual links · headings · navigation choices · index terms (keywords/metadata) · iconic labels.
- **Consistency dimensions to enforce:** style (capitalization, tense), presentation (typography), syntax (verb-vs-noun phrasing — pick one per set), granularity (parallel scope across siblings), audience (one vocabulary per scheme).
- **Sourcing labels:** harvest from your own content/metadata, from competitor/comparable sites, from **search-log analysis** (what users actually type), and from controlled-vocabulary research. User language beats internal jargon almost always.
- **The jargon trap:** internal/org labels ("Synergy Hub") fail users who don't share the mental model. Validate labels with card sorting and first-click tests (§11).
- **Iconography:** icons are labels too; almost none are universally understood without text. Pair icons with text unless the icon is genuinely conventional (home, search, hamburger, trash).

---

## §6 — Navigation systems (how people move)

Navigation answers three perpetual user questions: _Where am I? Where can I go? How do I get back?_

### Navigation types (Rosenfeld/Morville)

- **Global (primary)** — present everywhere; the top-level structure. Keep it stable.
- **Local (secondary)** — within a section; the current branch's children/siblings.
- **Contextual (inline/associative)** — links embedded in content ("related," "see also"); realizes the hypertext layer.
- **Supplemental** — sitemaps, A–Z indexes, guides; safety nets for when the primary nav fails.
- **Utility** — login, search, settings, cart; cross-cutting tools, kept visually distinct from content nav.

### Patterns

- **Breadcrumbs** — three kinds: **location** (where this page sits in the hierarchy), **path** (the trail you actually walked — mostly deprecated), **attribute** (the facets currently applied). Location breadcrumbs are the workhorse; they also relink to parents.
- **Mega-menus / fat footers** — expose breadth without deep clicking; good for large flat-ish structures; can overwhelm.
- **Faceted navigation** — filter panels; the UI realization of §4 faceting. Design for the zero-results state and for "applied filters" visibility.
- **Tabs, accordions, and progressive disclosure** — reveal structure on demand (§9).
- **Local "you are here" cues** — highlighting current section; non-negotiable for orientation.

### Wayfinding — Kevin Lynch, _The Image of the City_ (1960)

Lynch's five elements that make a _city_ legible transfer beautifully to digital environments:

1. **Paths** — the routes users travel (nav, links, flows)
2. **Edges** — boundaries between areas (section breaks, dividers)
3. **Districts** — distinct zones with shared character (sections with consistent styling)
4. **Nodes** — decision/junction points (landing pages, hubs, dashboards)
5. **Landmarks** — memorable reference points (the logo/home, a distinctive page)

Design test: can a dropped-in user answer "what kind of place am I in, and how do I leave?" using only these cues?

---

## §7 — Search & findability (finding a specific thing)

Browsing (§§3–6) and searching are complements, not substitutes. Power users and known-item seekers go straight to search. (But calibrate by substrate: for _personal_ collections, 30 years of measured behavior says navigation dominates and search is a last resort — see §14.1 before designing search-first.)

### Information-seeking modes — design for all four

1. **Known-item** — "I know exactly what I want." → fast, precise search; autocomplete; best bets.
2. **Exploratory** — "I'll know it when I see it." → faceted browse, recommendations, related content.
3. **Comprehensive / research** — "I need everything on X." → filters, saved searches, export.
4. **Re-finding** — "I had it before." → history, recents, bookmarks, stable URLs.

### Models of how people actually search

- **Berrypicking — Marcia Bates (1989):** real searches _evolve_; users pick up bits along the way and reformulate, rather than firing one perfect query at a static target. Design for query refinement, not one-shot retrieval.
- **Information foraging / information scent — Pirolli & Card (Xerox PARC):** users follow "scent" (cues suggesting a path leads to the goal) like animals foraging; they abandon a "patch" when scent weakens. Strong link labels and snippets = strong scent. This is the single most useful theory for nav/link design.
- **Kuhlthau's Information Search Process:** search has an _affective_ arc (uncertainty → optimism → confusion/frustration → clarity → confidence). Long research tasks need reassurance at the frustration trough.

### Search system components

Querying (parsing, operators, NLP) · indexing (what's searchable, fields, weighting) · results presentation (ranking, snippets, grouping) · refinement (facets, filters, sort) · helpers (autocomplete, did-you-mean, synonyms/query expansion, **best bets**/curated answers, zero-results recovery). Federated search spans multiple sources; faceted search marries search with §4.

---

## §8 — Content modeling & structured content (the shape of the content itself)

IA increasingly means modeling content as structured data so it can be reused across channels, not authored as pages.

- **Content types & content modeling** — define each _type_ (article, product, event, person) as a set of typed fields and relationships, independent of presentation. This is data modeling for content; it's what makes a headless CMS work.
- **COPE — Create Once, Publish Everywhere (NPR):** author structured content once; render to web, app, voice, syndication. Requires presentation-independent content.
- **Structured/modular content** — break content into reusable chunks with semantics, not formatted blobs. Enables reuse, personalization, and (now) clean LLM retrieval.
- **Atomic Design — Brad Frost (UI's parallel):** **atoms → molecules → organisms → templates → pages.** A compositional hierarchy for design systems; conceptually the same move as modular content applied to interface components.
- **Why it matters now:** structured content is the difference between a knowledge base an LLM can reliably ground on and a pile of pages it hallucinates around. Content modeling is becoming AI-retrieval architecture.

---

## §9 — Cognitive & perceptual laws (the constraints under everything)

You design against human perception and memory. These are the load-bearing constraints.

- **Gestalt principles** — the brain groups by **proximity, similarity, closure, continuity, common fate, figure/ground,** and **common region.** Layout _is_ IA: things placed together are read as related, regardless of your taxonomy. Proximity and common region are the strongest grouping cues you have.
- **Hick's Law** — decision time rises with the number and complexity of choices. Fewer, well-differentiated options beat many. Justifies progressive disclosure and curation.
- **Miller's "7±2"** — _frequently misapplied._ It's about short-term _memory_ span, not menu length. Don't artificially cap nav items at 7; do chunk long lists into labeled groups. The real lever is **chunking**, not the magic number.
- **Information scent** (see §7) — strong cues at decision points; weak scent → abandonment.
- **Cognitive load** — intrinsic (task difficulty) + extraneous (bad design) + germane (learning). IA's job is to crush extraneous load.
- **Progressive disclosure** — show the minimum now; reveal complexity on demand. The reconciliation of "power" and "simplicity."
- **Chunking** — group items into meaningful, labeled units; the antidote to long flat lists.
- **Serial position effect (primacy & recency)** — first and last items in a list are remembered best; put the most important options at the ends, not the middle.
- **Jakob's Law** — users spend most of their time on _other_ sites/apps and expect yours to work the same way. Convention is a feature; novel structures carry a learning tax you must justify.

---

## §10 — Design principles & heuristics (the rules of thumb)

### Dan Brown's Eight Principles of Information Architecture (_ASIS&T Bulletin_ 36(6), 2010 — cite the Wiley DOI 10.1002/bult.2010.1720360609; the old asis.org PDF is gone)

1. **Objects** — treat content as living things with lifecycles, not static pages.
2. **Choices** — offer fewer, meaningful choices at each point (Hick's Law as a principle).
3. **Disclosure** — show enough preview to let users predict what's behind a choice.
4. **Exemplars** — show examples of what's inside a category, not just its name.
5. **Front doors** — assume ≥50% of users arrive deep, not via the homepage (search/deep links). Every page is a potential entry point.
6. **Multiple classification** — provide several browsing schemes for the same content.
7. **Focused navigation** — keep each nav menu to one coherent scheme; don't mix.
8. **Growth** — assume content volume will grow; design structures that scale.

### Pervasive / Cross-channel IA heuristics — Resmini & Rosati (_Pervasive Information Architecture_)

For experiences that span devices, channels, and physical/digital touchpoints (the modern default):

- **Place-making** — help users get and keep a sense of where they are across channels.
- **Consistency** — fit purpose, context, and prior experience across touchpoints.
- **Resilience** — adapt to different users, contexts, and entry points.
- **Reduction** — manage information overload; show what's needed.
- **Correlation** — surface relevant relationships, suggest connections across the ecosystem.

### General heuristics worth taping to the wall

- One dominant organization scheme per level (§2).
- Make the current location obvious; always offer a way up and back (§6).
- Match labels to user language, validated by data (§5).
- Design the empty/zero-results and error states as first-class (§7).
- Defer hierarchy commitments when the model is uncertain — prefer faceting/metadata (§3.7, §4).

---

## §11 — Research & validation methods (proving the structure works)

Structure is a hypothesis until tested. The core methods:

- **Content inventory & audit** — enumerate what you have (inventory = full list; audit = quality/ownership/relevance judgment). The unglamorous prerequisite to any restructure.
- **Card sorting** — users group cards (content items) into categories:
  - **Open** — users create and name their own groups → reveals their mental model and vocabulary (use early).
  - **Closed** — users sort into _your_ predefined categories → validates a proposed structure.
  - **Hybrid** — predefined groups plus the option to add new ones.
- **Tree testing (reverse card sorting)** — give users a text-only version of your hierarchy and ask them to find where they'd look for a task. Isolates structure from visual design; the gold standard for validating a nav tree. Metrics: success rate, directness, time.
- **First-click testing** — where do users click first for a task? First click correctness strongly predicts overall task success.
- **Mental model diagrams — Indi Young** — map users' tasks/thinking against your features to find gaps and over-builds; aligns structure to cognition.
- **Findability/search-log analysis** — what users actually type reveals vocabulary, gaps, and demand (free, continuous, underused).
- **Journey maps & task analysis** — sequence the real-world flow the structure must support.

> Sequence that works: **inventory → open card sort (mental model) → draft structure → tree test (validate) → first-click (refine labels) → ship → search-log monitoring (maintain).**

---

## §12 — Personal & networked knowledge structures (for tools, notes, and second brains)

These are masterclass structures for organizing _your own_ information and for designing knowledge tools — directly relevant to dev tooling, docs, and LLM memory systems.

- **PARA — Tiago Forte:** four top-level buckets by _actionability_, not topic: **Projects** (active, with deadlines) · **Areas** (ongoing responsibilities) · **Resources** (topics of interest) · **Archives** (inactive). The insight: organize by how actionable something is, not what it's "about." Scales across any tool.
- **Zettelkasten — Niklas Luhmann:** atomic notes (one idea each), each with a unique ID, densely **linked** to others, plus an index of entry points. A bottom-up _network_ (3.4) that grows emergent structure rather than imposing a tree. The intellectual ancestor of bidirectional-link note apps.
- **Johnny.Decimal:** a numeric addressing scheme — **Areas** (10–19, 20–29…) → **Categories** (11, 12…) → **IDs** (11.01, 11.02). Gives every item a unique, memorable, stable address. Brilliant for file systems, repos, and any system needing durable references. Caps complexity by design (max 10 areas × 10 categories × 100 IDs).
- **Networked thought / "second brain"** — bidirectional links, transclusion, daily notes, and graph views; favors emergence (network) over hierarchy. Strong for synthesis and discovery, weak for guaranteed structure — pair with PARA or an index for a backbone.
- **The Garden and the Stream (Mike Caulfield)** — two complementary modes of digital info: the **Stream** (chronological, feed, in-the-moment) vs the **Garden** (cultivated, linked, revisited, topical). Most knowledge tools need both; conflating them is a common failure.

---

## §13 — Bridges to systems, data & enterprise architecture

The same structural thinking reappears when you decompose software. These are the IA-adjacent master structures for systems work.

### Data & domain modeling

- **Entity–Relationship Model (ERM)** — entities, attributes, relationships, cardinality. The relational database is literally a controlled, typed, faceted information architecture. Normalization is taxonomy hygiene; denormalization trades it for read performance.
- **Domain-Driven Design — Eric Evans:** the most IA-like software discipline.
  - **Ubiquitous language** = Covert's _ontology_ (§1): agree on what terms mean, in code and conversation.
  - **Bounded contexts** = districts/edges (§6, Lynch): explicit boundaries where a model and its language hold.
  - **Aggregates, entities, value objects** = the content model (§8) for behavior.
  - **Context mapping** = the relationships and integration patterns between contexts.
    DDD is information architecture applied to a domain's behavior.

### System decomposition & description

- **The C4 Model — Simon Brown:** a _hierarchy of zoom levels_ for describing software — **Context → Containers → Components → Code.** It's LATCH's Hierarchy scheme (§2) applied to architecture diagrams; pick the right altitude for the audience. The strongest antidote to incoherent architecture diagrams.
- **Layered architecture** — presentation/application/domain/infrastructure; a strict hierarchy (3.1) of dependency.
- **Hexagonal / Ports & Adapters & Clean/Onion architecture** — concentric containment isolating the domain from I/O; a deliberate edge/boundary structure (§6).
- **Event-driven / CQRS / Event Sourcing** — model the system as a _sequence_ (3.2) of immutable events; the log becomes the source of truth and all views are projections (3.7 database model, generated on demand).
- **Microservices vs monolith** — a decomposition (taxonomy) decision: where do the bounded-context edges fall, and what's the cost of crossing them?

### Enterprise-scale frameworks

- **Zachman Framework** — a 2-D matrix (3.3) for enterprise architecture: rows = perspectives (contextual, conceptual, logical, physical, detailed, operational) × columns = interrogatives (**What, How, Where, Who, When, Why**). A complete _ontology_ for describing an enterprise; heavyweight but rigorous.
- **TOGAF** — a process/method for developing enterprise architecture (governance + ADM cycle); pairs with a description framework like Zachman.

> **The throughline:** "by what principle do I group, what shape does it take, how tightly do I control the categories, and where do the boundaries fall" is the same question whether you're laying out a nav, modeling content, designing a taxonomy, or decomposing a system. This playbook is one set of answers reused across all of them.

---

## §14 — File systems & directories (personal → project → repo)

The oldest IA problem, and the one with the best empirical record. Two knowledge bases: measured human behavior (PIM research) and convergent layout standards. All findings below are sourced; research trail in `~/.claude/@research/ia-filesystem-data/` (2026-07).

### 14.1 The empirical ground — how people actually retrieve files

- **Navigation dominates; search is a last resort.** Across self-report, controlled tasks, and 4-week logging: folder navigation ≈ 56–68% of retrievals, search only **4–15%** (4.5% in the strictest log study). Search is used when folder memory fails, not as a first choice. (Bergman et al., _ACM TOIS_ 26(4) 2008; Fitchett & Cockburn, _IJHCS_ 74, 2015.)
- **Better search engines changed nothing.** Google Desktop / Spotlight users filed and navigated the same as users of older engines — no evidence indexing makes filing obsolete (Bergman et al. 2008). The young search _less_: search use correlates positively with age; over-50s searched ~4× more than twenty-somethings (Bergman & Whittaker, ASIS&T 2019). Watch for the ~11–13% of users who are "hyper-searchers" (43–64% of their retrievals).
- **Why:** fMRI shows folder navigation recruits the brain's spatial-wayfinding network (retrosplenial cortex, parahippocampus); search recruits linguistic areas — navigation rides on evolved spatial cognition (Benn, Bergman et al., _Sci. Reports_ 5:14719, 2015; n=17, mechanism evidence).
- **Real trees are big, deepish, and log-normal.** Largest modern scan (Dinneen, Julien & Frissen, CHI 2019: 348 collections, 49.2M files): typical collection 29k–193k files; mean max depth ~15; broadest point ~⅓ of the way down; branching factor ~3.6 per step; 15–18 folders at the root; nearly every measure log-normally distributed. Design for distributions, not averages. Folders are used "now more than ever" despite cloud + search.
- **Filers vs pilers (Malone, _ACM TOIS_ 1983):** piles aren't failure — they're short-term memory plus a _reminding_ surface. Deferred classification is rational because categorizing is cognitively hard. Digital sequels: a sanctioned inbox/dump zone beats pretending everyone files.
- **Three lifetimes (Barreau & Nardi, _SIGCHI Bulletin_ 1995):** _ephemeral_ (kept visible at top levels), _working_ (current projects), _archived_ (rarely touched — and people archive far less than designers assume). File placement doubles as a to-do system: finding and reminding are the same act. Elaborate filing schemes fail — they cost more than the information is worth.
- **Multi-classification fails in practice:** users barely use symlinks/aliases, and given folders + tags, they file more than they tag — even self-described tag-preferrers, who rarely apply more than one tag (Bergman et al. 2013; Dinneen & Julien, _JASIST_ 2020 review).

**Design consequences:** optimize the walk, not the query — stable locations, shallow-ish paths (typical file sits ~2 levels down), small folders (means ~12–19 files; users say they split at 3–7), strong scent at each step. Provide a dump zone. Treat visibility as a feature (reminding). Don't build tag-first or search-first personal systems against this evidence.

### 14.2 The canonical axes (what the standards agree on)

Seven axes recur across FHS, XDG, and every project-layout standard — they are the file-system versions of §2's organization schemes:

1. **Volatility / lifecycle** — FHS separates _static vs variable_; XDG separates config / data / state / cache / runtime by disposability (`~/.config`, `~/.local/share`, `~/.local/state`, `~/.cache`); pipelines separate `raw → interim → processed` with **raw immutable**. The single most load-bearing axis.
2. **Scope / shareability** — FHS's _shareable vs unshareable_; XDG's precedence-ordered search paths (user dirs override system dirs — a layered-override pattern reusable in any config system).
3. **Data / method / output separation** — TIER Protocol: `Data/ Scripts/ Output/`; Cookiecutter Data Science: `data/ notebooks/ models/ reports/` + a source package; research compendia: same triad with explicit relationships (Marwick, Boettiger & Mullen, _Am. Stat._ 72(1), 2018).
4. **Convention over invention** — organize "by the prevailing conventions of the community" so the layout is recognizable and tool-automatable (Marwick principle 1; Jakob's Law, §9, applied to directories).
5. **Names as parseable records** — see 14.3.
6. **Self-documenting root** — the README documenting the convention lives beside the files (Harvard HMS; TIER; Cornell).
7. **Structure scales with size** — start minimal, add layers only when needed (compendium model: `scripts/` → `R/ data/ tests/ vignettes/`); Nx monorepos cap nesting at 2–3 levels and widen instead of deepening.

Specs: FHS 3.0 (refspecs.linuxfoundation.org/FHS_3.0/) · XDG basedir (specifications.freedesktop.org/basedir/latest/) · CCDS (cookiecutter-data-science.drivendata.org) · TIER 4.0 (projecttier.org).

### 14.3 File naming — Jenny Bryan's three principles (+ institutional rules)

Names should be (1) **machine readable**, (2) **human readable**, (3) **sort well by default** (github.com/jennybc/how-to-name-files). Concrete rules, convergent with Harvard/Stanford/LoC guidance:

- No spaces, punctuation, accents, or case-dependence; ≤ ~50 chars.
- **Delimiters encode fields:** underscore between metadata fields, hyphen between words within a field → names parse into records (`2026-07-12_projectA_meeting-notes_v2.md`).
- **ISO 8601 dates** (`YYYY-MM-DD`) — alphabetical sort = chronological sort.
- Left-pad sequence numbers (`01`…); version suffix last (`_v2`); most-stable / most-sorted-on element leftmost; a human slug always (`01_marshal-data.R`).
- Sort order is a designed property, not an accident.

### 14.4 Reference layouts (steal, don't invent)

- **Data/analysis project** — CCDS: `data/{raw,interim,processed,external}` (raw immutable), `notebooks/` (exploration only; `<number>.<increment>-<initials>-<slug>`), `models/`, `reports/`, source package.
- **Reproducible research** — TIER 4.0: `Data/{Input,Analysis,Intermediate}`, `Scripts/{Processing,Analysis,Master}`, `Output/`, README + codebooks mandatory.
- **Monorepo** — `apps/` (deployable, thin) vs `libs|packages/` (shared, ~80% of code); group libs by owning scope; tag scope + type (`feature`/`ui`/`data-access`/`util`); layout is convention — tooling discovers projects by manifest, not folder position (Nx docs).
- **Unix-like system** — FHS's fixed top-level vocabulary; the lesson is a _small, closed, documented set of top-level names_, each the intersection of purpose × volatility × shareability.

---

## §15 — Datasets & research data (organizing a set of data)

A complete dataset-organization standard prescribes three layers — **structure**, **human documentation**, **machine documentation**. The same facts (variables, units, missing codes) deliberately appear at both reading levels.

### 15.1 Structure — tidy data (Wickham, _J. Stat. Software_ 59(10), 2014)

Codd's 3NF restated for statistics (Wickham's own lineage claim). Three rules: **each variable a column · each observation a row · each observational-unit type its own table.** The five messy-data diagnoses: column headers are values; multiple variables in one column; variables in both rows and columns; multiple unit types in one table; one unit spread across tables. Caveat from the paper: tidy _storage_ and analysis-ready (joined) shape can differ — that's §16.3's normalization tradeoff in miniature. Companion prescriptions (DataONE): layout mirrors the research design; keep data values separate from annotations/flags (own columns); avoid sparse matrices.

### 15.2 Human documentation — README + data dictionary

- **README for data** (Cornell Data Services, the de facto template): six sections — general info · file overview & relationships · sharing/access/license/citation · methods · per-file data-specific info (variables, units, missing codes) · references. Plain text, ISO 8601 dates, one README per logical cluster of files.
- **Data dictionary / codebook** (ICPSR-derived; Penn Libraries): one row per variable — name (exactly as in data), label, definition, question text, level & unit of measurement, allowed values + labels, **missing-data codes differentiated by reason**, universe/skip pattern, summary stats, notes. Build it during collection, not at publication — it enforces consistency while data accrues.

### 15.3 Machine documentation — FAIR + Data Package

- **FAIR (Wilkinson et al., _Scientific Data_ 2016; go-fair.org):** 15 sub-principles targeting _machine-actionability_. The skeleton: persistent identifier (F1) + rich metadata carrying that identifier (F2/F3) + indexed in a searchable registry (F4) + retrievable by open protocol (A1) + **metadata outlives the data** (A2) + formal vocabularies, themselves FAIR (I1/I2) + license, provenance, community standards (R1.x). FAIR ≠ open — access must be transparent, not necessarily free. It's a findability/reuse _contract_, not a layout.
- **Data Package v2 (datapackage.org, 2024):** the machine-readable README — one `datapackage.json` at the package root; required `resources[]` (one per file); recommended id/license/version/contributors/sources. Layered specs: Data Package → Data Resource → **Table Schema** (per-column types + constraints — the machine data dictionary) → CSV Dialect. The pragmatic way to operationalize FAIR for a folder of files.
- **Versioning is identity, not housekeeping:** each version gets a citable identifier plus a statement of what changed (DataONE; Data Package `version`/`id`).

### 15.4 Describing datasets to the world — the metadata-standards stack

Layered, not competing (all verified against the current specs):

| Need                                                                    | Standard                                                                                                                                       |
| ----------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| Minimal descriptive fields on any resource; cross-collection harvesting | **Dublin Core** — 15 elements; use the `dcterms` namespace (DCMI, 2020)                                                                        |
| Describe a _catalog_ of datasets; portal federation; EU/gov mandates    | **DCAT v3** (W3C Rec 2024) — Catalog / Dataset / **Distribution** (one logical dataset, many physical forms) / DataService / DatasetSeries     |
| Make one dataset findable via web search                                | **schema.org/Dataset** JSON-LD on the landing page — Google requires `name` + `description`; recommends DOI, license, `distribution`, coverage |
| Publish/exchange a taxonomy or vocabulary; map between vocabularies     | **SKOS** (W3C 2009) — prefLabel/altLabel, broader/narrower/related, exactMatch/closeMatch                                                      |
| _Design_ the thesaurus itself (term form, BT/NT validity, facets)       | **ISO 25964** (coexists with ANSI/NISO Z39.19 — it does not replace it)                                                                        |
| Long-term preservation: fixity, migration events, rights over time      | **PREMIS** (LoC) — administrative plane; pair with DC's descriptive plane                                                                      |

dcterms is the substrate; DCAT structures catalogs on it; schema.org is the search-engine projection of the same record; SKOS carries the vocabulary used in `dcat:theme`/`dc:subject`.

---

## §16 — Data at analytics scale (lakes, warehouses, catalogs)

### 16.1 The quality-gradient axis (medallion & zone models)

Every analytics org converges on the same top-level scheme — a **trust/refinement gradient**, not a subject taxonomy: Databricks' bronze (raw, append-only, source-shaped) → silver (validated, deduped, "at least one non-aggregated representation of each record") → gold (business-shaped aggregates) ≈ Capital One's landing/raw → standardized → consumption (+ exploratory sandbox off the promotion path). The invariants: **an immutable as-received zone · a validated canonical zone · consumer-shaped zones · a sandbox outside the gradient.** Two cautions, both documented: the labels are unstandardized and don't self-define — teams diverge on what "silver" means unless each layer has a **written contract** (inputs, guarantees, audience); and the 3-tier scheme leaks for real-time/operational serving (critics propose a fourth serving tier; Databricks itself calls medallion "recommended, not a requirement").

### 16.2 Namespace vs metadata — where the organizing scheme lives

Hive-style `key=value/` directory partitioning encodes one classification axis into the physical namespace. Documented failure modes: **leaky abstraction** (query the natural column instead of the synthetic partition column → silent full scan), **schema pollution** (physical concerns as logical columns), **frozen granularity** (changing monthly→daily = rewrite everything), **small-files explosion** at high cardinality. Modern table formats move the scheme into metadata: Iceberg **hidden partitioning** (partitions as transforms — `day(ts)`, `bucket(16, id)` — plus **partition evolution** without rewriting old data); Delta **liquid clustering** (flat file layout, re-clusterable keys; vendor-argued, no published benchmarks). The IA lesson generalizes: _a browsable namespace and an efficient retrieval structure can be decoupled_ — at scale, the catalog + table definition is the IA and the directory tree is an implementation detail. This is §3.7 (database/bottom-up) winning over §3.1 (hierarchy) as volume grows.

### 16.3 Modeling schools — layer them, don't pick one

| School                         | Structure                                                                                                                                                            | Wins when                                                                                                                                                                                                            |
| ------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Kimball** (kimballgroup.com) | Star schemas: fact tables + denormalized dimensions; conformed dimensions; **bus matrix** (processes × dimensions) as the integration plan; SCD types 0–7 for change | BI-first, incremental delivery, analyst legibility                                                                                                                                                                   |
| **Inmon** CIF                  | 3NF EDW as integrated "single version of the truth"; dimensional marts downstream                                                                                    | Many sources, enterprise consistency worth the up-front modeling                                                                                                                                                     |
| **Data Vault 2.0** (Linstedt)  | **Hubs** (business keys) / **Links** (relationships) / **Satellites** (attributes + history, append-only); hash keys                                                 | Volatile sources, audit/compliance (row-level source + load-date), parallel loading; not query-friendly — project star marts on top                                                                                  |
| **One Big Table**              | Pre-joined wide denormalized table                                                                                                                                   | Columnar engine + read-heavy dashboards/ML features. Only measured comparison found: 25–49% faster than the equivalent star at ~2× storage (Fivetran TPC-DS benchmark, 2022 — single vendor benchmark, attribute it) |

Modern consensus is **layering**: integration layer (3NF or Data Vault) → dimensional presentation → optional OBT serving extracts. Normalize where one fact must live in one place (write/integration); denormalize where scan speed and cognitive load dominate (read/serving). Same tradeoff as §15.1's tidy-storage-vs-analysis-shape, at warehouse scale.

**Element naming:** ISO/IEC 11179-5 (2015) is the standards-body anchor — names built as _object class + property + representation term_ (`employee_birth_date`); it defines the rules for building a naming convention (scope, authority, semantic, syntactic, lexical, uniqueness) rather than one convention. Celko's _SQL Programming Style_ is the bridge into working DDL.

### 16.4 Centralized vs mesh (the org-scale tension)

Dehghani's **data mesh** (martinfowler.com, 2019/2020): centralized lakes/warehouses fail because pipeline stages are "orthogonal to the axis of change" and central teams are siloed from domain knowledge. Four principles: domain-oriented ownership · **data as a product** (discoverable, addressable, trustworthy, self-describing) · self-serve platform · **federated computational governance**. Canonical but explicitly non-empirical — an argument by analogy to microservices, not a measured result. The IA reading: one global scheme with a bottlenecked maintainer vs federated local schemes with an interoperability contract — and principle 4 is load-bearing, because decentralization without federated standards just reproduces silos. (Vendor gravity is drifting this way: Microsoft retired its zone-model guidance for a data-products framing, 2026.)

### 16.5 Discovery past the browse threshold

Past a few thousand assets, browsing the namespace stops working and discovery becomes search + trust signals (owner, freshness, lineage, popularity ranking) over harvested metadata — the data catalog. Self-reported anchor: Lyft put ~25% of data scientists' time into data discovery ("about a third" in Grover's podcast telling) and reported Amundsen cut time-to-discover to "5% of the pre-Amundsen baseline" (eng.lyft.com, 2019; a "+30% productivity" figure circulating in secondary sources appears in neither primary post). Same pattern as 16.2: at scale, authoritative organization lives in metadata, not the namespace.

---

## §17 — Quick decision guide (problem → structure)

| If your problem is…                                          | Reach for…                                                                              |
| ------------------------------------------------------------ | --------------------------------------------------------------------------------------- |
| Large heterogeneous catalog, users with different priorities | Faceted classification (§3.5/§4) + faceted nav (§6)                                     |
| Content with natural levels, general→specific browsing       | Hierarchy (§3.1), validated by tree test (§11)                                          |
| Mandatory ordered process                                    | Sequence (§3.2) with progress + escape hatches                                          |
| Many-to-many relationships, exploration matters              | Hypertext/network (§3.4) layered on a hierarchy                                         |
| Large uniform set, frequently re-sorted                      | Database/bottom-up (§3.7) with generated views                                          |
| Users disagree on the "right" category                       | Multiple classification (§10 #6) / polyhierarchy / facets                               |
| Inconsistent terms causing duplicate/missed content          | Controlled vocabulary + synonym rings (§4)                                              |
| Need machine reasoning / semantic retrieval / RAG grounding  | Ontology / knowledge graph + structured content (§4, §8)                                |
| Cross-device / cross-channel experience                      | Pervasive IA heuristics (§10)                                                           |
| Organizing your own work/notes/tooling                       | PARA · Zettelkasten · Johnny.Decimal (§12)                                              |
| Decomposing a software domain                                | DDD + bounded contexts; describe with C4 (§13)                                          |
| Don't know the user's mental model yet                       | Open card sort first (§11), defer structure commitments                                 |
| Users keep landing on the wrong page                         | First-click test + fix labels/scent (§5, §7, §11)                                       |
| Nav feels overwhelming                                       | Chunk + progressive disclosure + Hick's Law (§9)                                        |
| Laying out a project/repo directory tree                     | Lifecycle + data/method/output axes; steal a reference layout (§14.2, §14.4)            |
| Naming files (or any sortable artifact)                      | Bryan's three principles + ISO 8601 + delimiter-encoded fields (§14.3)                  |
| Personal/team file store that must be re-findable            | Optimize navigation, not search: shallow stable paths, small folders, dump zone (§14.1) |
| Publishing or documenting a dataset                          | Tidy structure + README/data dictionary + datapackage.json + FAIR (§15)                 |
| Choosing dataset/catalog metadata standards                  | The layered stack: dcterms → DCAT → schema.org → SKOS (§15.4)                           |
| Organizing a data lake/warehouse                             | Quality-gradient zones with written layer contracts (§16.1)                             |
| Partitioning large tables / choosing physical layout         | Metadata-encoded schemes over namespace-encoded (§16.2)                                 |
| Choosing a warehouse modeling approach                       | Layer the schools: integration → dimensional → OBT serving (§16.3)                      |
| Naming database elements/columns                             | ISO/IEC 11179-5 pattern: object + property + representation (§16.3)                     |
| One data org, many domains fighting over the schema          | Mesh tradeoff: federate ownership only with a governance contract (§16.4)               |

---

## §18 — The canon (go deeper)

**Core texts**

- Rosenfeld, Morville & Arango — _Information Architecture: For the Web and Beyond_ (4th ed.) — the polar bear book; the spine of the discipline.
- Abby Covert — _How to Make Sense of Any Mess_ — the best short, accessible treatment; ontology/taxonomy/choreography.
- Jesse James Garrett — _The Elements of User Experience_ — the five planes.
- Dan Brown — _Communicating Design_ — the eight principles + deliverables.
- Donna Spencer — _A Practical Guide to Information Architecture_ & _Card Sorting_ — methods.
- Christina Wodtke & Austin Govella — _Information Architecture: Blueprints for the Web_.
- Resmini & Rosati — _Pervasive Information Architecture_ — cross-channel/ecosystem IA.
- Indi Young — _Mental Models_ — research-driven structure.

**Foundational / adjacent**

- Richard Saul Wurman — _Information Anxiety_ — LATCH and the philosophy of organizing.
- Kevin Lynch — _The Image of the City_ — wayfinding (paths/edges/districts/nodes/landmarks).
- Vannevar Bush — "As We May Think" (1945) — the Memex; root of hypertext.
- S.R. Ranganathan — _Colon Classification_ / _Five Laws of Library Science_ — faceting and first principles.
- Marcia Bates — "The Design of Browsing and Berrypicking Techniques" (1989).
- Pirolli & Card — _Information Foraging Theory_.
- Eric Evans — _Domain-Driven Design_; Simon Brown — the C4 model (c4model.com).
- Brad Frost — _Atomic Design_.
- Steve Krug — _Don't Make Me Think_ — usability lens on the whole thing.

**File systems & data (§§14–16)**

- Bergman & Whittaker — _The Science of Managing Our Digital Stuff_ (MIT Press, 2016) — the PIM synthesis: curation lifecycle, why folders beat search/tags, the user-subjective approach.
- Dinneen & Julien — "The ubiquitous digital file" (_JASIST_ 71(1), 2020) — the field's literature review; every folder-statistics number in §14.1 traces here or to Dinneen et al. CHI 2019.
- Wickham — "Tidy Data" (_J. Stat. Software_ 59(10), 2014); Wilkinson et al. — FAIR principles (_Scientific Data_, 2016).
- Kimball & Ross — _The Data Warehouse Toolkit_ (3rd ed.); Inmon — _Building the Data Warehouse_; Linstedt — Data Vault (TDAN, 2002–).
- Dehghani — _Data Mesh_ (O'Reilly, 2022) and the two martinfowler.com essays (2019/2020).
- Specs to cite directly: FHS 3.0 · XDG basedir · Data Package v2 · DCAT v3 · SKOS · ISO 25964 · ISO/IEC 11179-5 · PREMIS v3.

---

_Built as a pick-from reference. The structures don't compete — most real systems compose several. The discipline is in choosing the dominant one deliberately and layering the rest on purpose._
