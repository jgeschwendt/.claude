---
name: information-architecture
description: A corpus of information-architecture structures — organization schemes, taxonomies, navigation, labeling, content models, knowledge structures, and their bridges into software/data/system design — with a decision guide for choosing among them. Use when designing or restructuring how information is organized in ANY system — site/app navigation, menus, a taxonomy or tag system, a knowledge base or docs structure, file/directory layout, a database or content schema, API resource shapes, an LLM memory or RAG corpus, naming/labeling things, decomposing a domain into services/modules, or organizing notes and personal knowledge. Trigger phrases include "how should I organize/structure/group…", "what should I call…", "taxonomy", "categories", "navigation", "sitemap", "schema design", "content model", "this structure feels wrong". Not for visual/layout design or one-off CSS work.
---

# Information Architecture

A reference to pick from — not a methodology to follow. The full corpus lives in `references/playbook.md` (~600 lines, 18 sections). Do not read it whole: route with the axes and decision guide below, then read only the sections that match — locate a section with `rg -n '^## §4' ${CLAUDE_SKILL_DIR}/references/playbook.md` and Read from that line offset.

## The decision axes

Every IA problem is choices on these axes. Identify which axis the current problem sits on, then read that section of the playbook:

1. **By what principle do I group things?** → §2 Organization schemes (LATCH, exact vs ambiguous)
2. **What overall shape does the grouping take?** → §3 Organization structures (hierarchy, sequence, matrix, network, faceted, hub-and-spoke, database)
3. **How rigorously do I control the categories?** → §4 Classification & taxonomy (controlled vocab → taxonomy → thesaurus → ontology → folksonomy)
4. **What do I call things?** → §5 Labeling systems
5. **How do people move through it?** → §6 Navigation & wayfinding
6. **How do people find a specific thing?** → §7 Search & findability (seeking modes, berrypicking, information scent)
7. **How is the content itself shaped?** → §8 Content modeling & structured content
8. **What constrains all of this?** → §9 Cognitive & perceptual laws
9. **What principles keep me honest?** → §10 Design heuristics (Dan Brown's eight, pervasive IA)
10. **How do I validate it?** → §11 Research methods (card sorting, tree testing, first-click)

Substrate-specific sections — read these when the problem IS the substrate:

11. **Laying out or naming files/directories?** → §14 File systems (PIM evidence, FHS/XDG axes, Bryan naming, reference layouts)
12. **Organizing or publishing a set of data?** → §15 Datasets (tidy data, README/data dictionary, FAIR, Data Package, metadata-standards stack)
13. **Data at lake/warehouse/catalog scale?** → §16 Analytics-scale (zone contracts, partitioning, modeling schools, mesh, catalogs)
14. **Structuring an LLM agent's own context — skills, memory, references?** → §12 agent-context structures (progressive disclosure, router-over-read, atomic memory)

Also: §1 foundational frames (Three Circles, Five Planes, ontology/taxonomy/choreography), §12 personal/networked knowledge (PARA, Zettelkasten, Johnny.Decimal), §13 bridges to software/data/enterprise architecture (DDD, C4, ERM, event sourcing), §17 decision guide, §18 the canon.

## Quick decision guide (problem → structure)

Mirror of playbook §17 — this copy is the always-loaded router; a row added there is added here too.

| If the problem is…                                           | Reach for…                                                          |
| ------------------------------------------------------------ | ------------------------------------------------------------------- |
| Large heterogeneous catalog, users with different priorities | Faceted classification (§3.5/§4) + faceted nav (§6)                 |
| Content with natural levels, general→specific browsing       | Hierarchy (§3.1), validated by tree test (§11)                      |
| Mandatory ordered process                                    | Sequence (§3.2) with progress + escape hatches                      |
| Many-to-many relationships, exploration matters              | Hypertext/network (§3.4) layered on a hierarchy                     |
| Large uniform set, frequently re-sorted                      | Database/bottom-up (§3.7) with generated views                      |
| Users disagree on the "right" category                       | Multiple classification / polyhierarchy / facets (§4, §10)          |
| Inconsistent terms causing duplicate/missed content          | Controlled vocabulary + synonym rings (§4)                          |
| Machine reasoning / semantic retrieval / RAG grounding       | Ontology / knowledge graph + structured content (§4, §8)            |
| Cross-device / cross-channel experience                      | Pervasive IA heuristics (§10)                                       |
| Organizing own work/notes/tooling                            | PARA · Zettelkasten · Johnny.Decimal (§12)                          |
| Decomposing a software domain                                | DDD + bounded contexts; describe with C4 (§13)                      |
| User's mental model unknown                                  | Open card sort first (§11), defer structure commitments             |
| Users keep landing in the wrong place                        | First-click test + fix labels/scent (§5, §7, §11)                   |
| Nav/options feel overwhelming                                | Chunk + progressive disclosure + Hick's Law (§9)                    |
| Laying out a project/repo directory tree                     | Lifecycle + data/method/output axes; steal a layout (§14)           |
| Naming files or sortable artifacts                           | Machine-readable · human-readable · sorts well; ISO 8601 (§14.3)    |
| Re-findable personal/team file store                         | Optimize navigation, not search — shallow stable paths (§14.1)      |
| Publishing/documenting a dataset                             | Tidy + README/dictionary + datapackage.json + FAIR (§15)            |
| Choosing dataset/catalog metadata standards                  | Layered stack: dcterms → DCAT → schema.org → SKOS (§15.4)           |
| Organizing a data lake/warehouse                             | Quality-gradient zones with written layer contracts (§16)           |
| Partitioning large tables / choosing physical layout         | Metadata-encoded schemes over namespace-encoded (§16.2)             |
| Choosing a warehouse modeling approach                       | Layer the schools: integration → dimensional → OBT serving (§16.3)  |
| Naming database elements/columns                             | ISO/IEC 11179-5 pattern: object + property + representation (§16.3) |
| One data org, many domains fighting over the schema          | Mesh tradeoff: federate ownership only with governance (§16.4)      |
| Structuring an LLM agent's context (skills, memory, refs)    | Progressive disclosure + router-over-read + atomic memory (§12)     |

## Ground rules (apply even without opening the playbook)

- **One dominant organization scheme per navigation level.** Mixing "by topic" and "by audience" in one list is the most common IA defect. Deliberate hybrids are fine when the layers are visibly separate (§2).
- **Composites are normal.** Real systems layer structures: a hierarchical backbone, faceted filters on large sets, associative links, a database model underneath. Choose the dominant structure deliberately; layer the rest on purpose.
- **Ontology first.** Agree on what terms mean before arranging them — the most-skipped, highest-leverage step.
- **Defer hierarchy commitments when the model is uncertain** — prefer metadata/faceting over premature trees.
- **User language beats internal jargon.** Source labels from what users actually type, not org vocabulary.
- **Structure is a hypothesis until tested** — card sort to discover, tree test to validate.
- **Structure migrations are one-way doors** — once habits, links, and tooling build on a layout, reversal is costly; run the commit decision through sequential-thinking's gate (stakes × reversibility) before migrating, not after.
- **At personal/project scale, optimize navigation, not search** — measured: search is 4–15% of file retrievals and better engines never changed that. At catalog scale (thousands of assets) the reverse: the namespace stops being the IA and metadata/search takes over.
- **Partition by lifecycle first** — raw/immutable vs derived, config vs cache vs state. The volatility axis is the most load-bearing grouping principle for files and data.

## Worked traversal (the routing behavior, demonstrated)

> "Our team drive is a mess — hundreds of docs, everyone files differently, nobody can find anything."

1. Axis check: grouping principle contested → §2, §4; substrate is files → §14. Three sections read, not eighteen.
2. Diagnosis from §2 + §14.1: mixed schemes at one level (topic + audience + date), and retrieval here is navigation-shaped — search is 4–15% of file retrievals, so better search won't save it.
3. Layered recommendation, not one structure: lifecycle partition first (active/archive), one dominant scheme per level (project, then document type), Bryan naming with ISO 8601 for sortables, a controlled vocabulary for the dozen contested labels — validated by a 15-minute card sort (§11) before migrating, because the migration is a one-way door (→ sequential-thinking's gate).
