# The Memory System

One bank per working directory under `~/.claude/@memory`. Sessions write memories the moment
they surface, dissolve whole conversations at death, and read their bank back at birth.
No human review anywhere in the loop — verification is a judge pass, and the dashboard is
a viewer/editor, not a gate. `Core.Memory` (`memory.ex`) is the single format authority;
every other writer (the `/dissolve` skill, batch jobs) mirrors it byte-for-byte.

## System overview

```mermaid
flowchart LR
    subgraph session["Live session (any cwd)"]
        A[memory surfaces mid-task] -->|write at the time of attention| STG
        K["/dissolve at session end"]
    end

    subgraph web["@apps/web dashboard"]
        UI["Dissolve a conversation<br/>(MemoriesLive)"]
        VIEW["browse / edit / merge"]
    end

    STG[".staging.json<br/>(inbox + judge-failure fallback)"]

    subgraph pipe["Autonomous pipeline"]
        X[extract candidates] --> J{judge pass}
        J -->|COMMIT| C["commit_memory/1"]
        J -->|DROP| D[discarded]
        J -->|judge unavailable| STG
    end

    K --> X
    UI -->|"distill_session/2"| X
    STG -->|"drained by next /dissolve"| J

    C --> BANK[("~/.claude/@memory/&lt;bank&gt;/<br/>&lt;type&gt;_&lt;slug&gt;.md + MEMORY.md")]
    VIEW --- BANK
    BANK -->|"read at session start<br/>(CLAUDE.md § Memory)"| session

    K -->|kill| ARC["@log/archive/&lt;date&gt;/&lt;sid&gt;.jsonl.gz<br/>(diary fuel, un-resumable)"]
    UI -->|"consume-on-dissolve<br/>Transcripts.delete_session/2"| ARC
```

Three write paths, one pipeline: everything funnels through **extract → judge → commit**.
The only differences are who extracts (a live session with its own context, or `claude -p`
over a flattened transcript) and who judges (subagents for the skill, a second `claude -p`
call for the dashboard).

## Life of a memory

```mermaid
stateDiagram-v2
    [*] --> Candidate: extracted from conversation /<br/>staged at time of attention
    Candidate --> Committed: judge COMMIT
    Candidate --> Dropped: judge DROP<br/>(dup · derivable · ephemeral ·<br/>unsupported by evidence)
    Candidate --> Staged: judge unavailable<br/>(fallback — never lose an extraction)
    Staged --> Candidate: next /dissolve drains the inbox
    Committed --> Superseded: a later memory commits<br/>with this file in replaces
    Superseded --> [*]: file removed by commit_memory/1
    Committed --> [*]: delete_memory/2 (dashboard, manual)
```

Judge bars (identical in the skill and `Core.Memory.judge/2`): **durable** (useful in a
future, unrelated session) · **non-derivable** (not recoverable from code/git/CLAUDE.md) ·
**one idea per memory** · **description specific enough to trigger recall** · evidence
supports the claim. Tie-break: _when in doubt, drop_ — with no reviewer downstream, a
missed memory costs less than committed noise.

## Banks and memory files

Bank id = cwd with every non-alphanumeric character replaced by `-` (`sanitize/1`):
`/Users/jlg/GitHub/jgeschwendt/grove` → `-Users-jlg-GitHub-jgeschwendt-grove`.

```
~/.claude/@memory/
├── .staging.json                     # inbox / fallback queue (array of memory maps)
├── _steering.md                      # optional curation guidance (else @default_steering)
└── <bank>/
    ├── MEMORY.md                     # regenerated index — never hand-edited
    ├── <type>_<slug>.md              # one memory per file
    └── _*.md                         # underscore-prefixed files are skipped
```

Memory file serialization (`serialize_memory/1`):

```markdown
---
name: <human-readable title, ≤90 chars>
description: <one-line recall summary, whitespace collapsed>
type: feedback | project | reference | user
source: <session uuid — line omitted if unknown>
---

<body — for feedback/project: the rule, then **Why:**, then **How to apply:**>
```

Filename mechanics (`file_name/1`, `commit_file_name/2`):

```mermaid
flowchart TD
    N["name"] --> S["slug: downcase ·<br/>[^a-z0-9]+ → _ · trim _ · max 60"]
    S --> E{slug empty?}
    E -->|yes| H["x + sha1(name)[0..7]"]
    E -->|no| F["&lt;type&gt;_&lt;slug&gt;.md"]
    H --> F
    F --> C{"target exists AND holds a<br/>different memory AND is not<br/>in this commit's replaces?"}
    C -->|yes| X["suffix _2, _3, … — never clobber"]
    C -->|no| W[write]
    X --> W
```

`commit_memory/1` then: removes each `replaces` file (bank-local plain filenames only —
`writable?/1` + `Core.Store.component?/1` block traversal and `auto:` banks), writes the
memory, prunes same `bank`+`name` entries from `.staging.json`, and regenerates `MEMORY.md`
— fixed frontmatter header, one line per memory in sorted-filename order:
`- [<name>](<file>) — <description, ≤150 chars>`.

## The two dissolve flows

### Dashboard: `distill_session/2` (one conversation, two `claude -p` calls)

```mermaid
sequenceDiagram
    participant U as MemoriesLive
    participant M as Core.Memory
    participant CL as claude -p
    participant B as bank on disk

    U->>M: distill_session(project, id)
    M->>M: flatten(session) — whole conversation, ≤60k chars
    M->>CL: extract prompt (steering + types + shape)
    CL-->>M: 0–8 candidates (JSON)
    M->>B: read existing memories (dedup context)
    M->>CL: judge prompt (bars + existing memories)
    alt judge returns verdicts
        CL-->>M: commit/drop + replaces per candidate
        M->>B: commit_memory/1 for each survivor
        M-->>U: %{memories, dropped, staged: 0}
        U->>U: Transcripts.delete_session — consume-on-dissolve
    else judge unparseable
        M->>M: write_staging(candidates) — fallback, nothing lost
        M-->>U: %{memories: [], staged: n}
        Note over U: transcript kept for retry
    end
```

### Session end: the `/dissolve` skill (this session's context, subagent harness)

```mermaid
sequenceDiagram
    participant S as dying session
    participant J as judges ×2 (subagents)
    participant B as banks
    participant A as auditor (subagent)

    S->>S: resolve bank · load steering + inbox
    S->>S: extract candidates (with verbatim evidence quotes)
    par quality judge
        S->>J: candidates + steering → COMMIT/REVISE/DROP
    and dedup judge
        S->>J: candidates + bank path → NEW/DUP/SUPERSEDES
    end
    J-->>S: verdicts (nothing commits on the lead's sole judgment)
    S->>B: commit survivors + drain inbox (mirrors commit_memory/1 exactly)
    S->>A: manifest + format spec
    A-->>S: PASS | FAIL (fix once, re-audit; a 2nd FAIL is reported, never hidden)
    S->>S: drain rules/learn-code.md → rules/*.md
    S->>S: kill — transcript gzip-archived to @log/archive/<date>/
```

The skill's commit step cites `memory.ex` (`serialize_memory/1`, `commit_file_name/2`,
`regen_index/1`, `commit_memory/1`) as its source of truth — on any drift, this code wins.

## Read path

Every session's CLAUDE.md § Memory contract: at start, if a bank matches the cwd
(case-insensitive — the store has casing drift, reuse the existing dir), read its
`MEMORY.md` and treat memories as background context — point-in-time observations, verify
before asserting. Mid-session durable _instructions_ route through the Golden Rule
(artifacts), not memory; memory holds _observations_.

## Bank kinds

| Kind    | Source                                                           | Writable            |
| ------- | ---------------------------------------------------------------- | ------------------- |
| managed | `~/.claude/@memory/<bank>/` — this system                        | yes (`writable?/1`) |
| `auto:` | Claude Code's own `projects/*/memory/` dirs                      | read-only           |
| seeded  | `skills/sandman/memories` corpus, copied once (`.seeded` marker) | as managed          |

Banks whose name starts with `_` or `.` are never targeted; the dashboard skips them.

## What staging still is (and isn't)

`.staging.json` is no longer a review queue. It has exactly two legitimate populations:

1. **Inbox** — memories written at the time of attention by live sessions (cheap, no
   ceremony mid-task). The next `/dissolve` from any session drains them through the
   judge, whatever bank they target.
2. **Fallback** — a dashboard dissolve whose judge call failed parks its candidates here
   instead of losing them; the transcript is kept so the dissolve can be retried.

`merge_memories/2` (dashboard editor) still stages its merged candidate — an interactive
edit the user completes with one click, not an autonomous path. Entry shape mirrors
`read_staging/0`: `{bank, body, description, name, replaces, source, type}`; malformed
entries (no name/bank) are dropped rather than allowed to crash a later commit.

## Retention

```mermaid
flowchart LR
    T["projects/&lt;proj&gt;/&lt;sid&gt;.jsonl<br/>(live transcript)"] -->|"/dissolve · /delete ·<br/>UI consume-on-dissolve ·<br/>batch sweeps"| G["@log/archive/&lt;date&gt;/&lt;sid&gt;.jsonl.gz<br/>+ &lt;sid&gt;.subagents.tar.gz"]
    G --> DRM["diary's daily dream (fuel)"]
    G -.->|recoverable by hand| T2["gunzip — but claude --resume<br/>needs a live .jsonl: un-resumable"]
```

Memories are the durable residue; transcripts are compact-deleted (gzip-archived, ~10×
smaller, recoverable, un-resumable). Nothing is ever erased outright.
