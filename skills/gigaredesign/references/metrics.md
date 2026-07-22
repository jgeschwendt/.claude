# Metrics — scoring candidates, guarding the shipped design

Metrics rank the three candidate designs against the same map evidence, and become the shipped design's regression guards.
They are evidence for the judge, never the judge itself — a number tells you where to look, not what to conclude.
Trends across the migration beat absolute thresholds; a component that worsens on every axis is the signal, not a single reading that trips a line.
Check tool availability before wiring anything (`which <tool>` / a `bunx <pkg> --version` dry-run); a missing tool means compute the metric by its described procedure — never silently drop an axis.

## Scoring a design against the map

Score all three candidates on these axes from the SAME map data. The map already names every component and its file set — reuse that partition; don't recompute boundaries per candidate.

- **Afferent coupling Ca** — count of components that depend ON a component (incoming).
  - **compute by** for each component, count distinct other components importing any file it owns — from the map's import edges, or `git grep -l` the component's exported symbols and bucket hits by owning component.
  - **read it as** high Ca = many dependents = a stable core that must not churn; a high-Ca component that also changes often is a design smell.
  - **gaming risk** merging everything into one hub inflates nothing but hides coupling inside a component where these metrics can't see it.

- **Efferent coupling Ce** — count of components a component depends ON (outgoing).
  - **compute by** count distinct other components it imports from (same edge set, other direction).
  - **read it as** high Ce = depends on many things = fragile, hard to reuse in isolation.
  - **gaming risk** collapsing dependencies behind a single façade component drops the number while the real fan-out survives one hop away.

- **Instability I = Ce / (Ce + Ca)** — 0 = maximally stable (only depended upon), 1 = maximally unstable (only depends) (per https://en.wikipedia.org/wiki/Software_package_metrics, verified 2026-07-15).
  - **compute by** from the Ca/Ce counts above; define I = 0 for isolated components (Ce+Ca = 0).
  - **read it as** healthy designs show a gradient — stable cores low, leaf/UI components high; the failure mode is a component depended upon by many (low expected I) that itself depends on many (high actual I).
  - **gaming risk** none directly — I is a ratio; game it only by gaming Ca/Ce.

- **Abstractness A = (abstract classes + interfaces) ÷ total types** in a component — 0 = all concrete, 1 = all abstract (per https://en.wikipedia.org/wiki/Software_package_metrics, verified 2026-07-15).
  - **compute by** count interface/trait/protocol/abstract declarations ÷ total type declarations (`rg -c` the language's abstract/interface keywords vs. total type keywords per component). For languages without formal abstract types (Elixir, Go), proxy with behaviour/protocol/interface definitions ÷ modules.
  - **read it as** a proxy for "is this component a contract or an implementation," feeding D below; not meaningful alone.
  - **gaming risk** interface-per-class ceremony inflates A without adding real abstraction.

- **Distance from the main sequence D = |A + I − 1|** — perpendicular distance from the ideal line A + I = 1; 0 = on the sequence, 1 = worst (per https://en.wikipedia.org/wiki/Software_package_metrics, verified 2026-07-15).
  - Note: Martin's canonical form is `|A + I − 1|`; some tools (e.g. pdepend) normalize to `|A + I − 1| ÷ √2` — state which you use and stay consistent across candidates.
  - **read it as** high D flags the two pain zones — the _zone of pain_ (A≈0, I≈0: concrete AND depended-upon, rigid to change) and the _zone of uselessness_ (A≈1, I≈1: abstract AND nothing uses it). A candidate whose components cluster near the main sequence beats one with outliers in either zone.
  - **gaming risk** chasing D=0 everywhere manufactures pointless abstraction in leaf components that should just be concrete.

- **Module cohesion** — do a component's files change together and reference each other?
  - **compute by** two proxies: (1) LCOM-style — fraction of intra-component file pairs sharing at least one import/symbol reference (high = tight); (2) git co-change ratio — of commits touching any file in the component, fraction touching ≥2 of its files:
    ```
    git log --format=%H --name-only -- <component-glob>
    # per commit: does it touch ≥2 of the component's files? ratio = (such commits) ÷ (all commits touching the component)
    ```
  - **read it as** high co-change (>~0.5) + high reference-sharing = a real component; files that never change or import together are squatters that belong elsewhere.
  - **gaming risk** a component defined so broadly that everything "co-changes" trivially — normalize against total commit volume.

- **Cross-boundary co-change coupling** — pairs of files in DIFFERENT components that keep committing together; the design should MINIMIZE this.
  - **compute by** walk history, split into per-commit file sets, emit every file pair that spans two components, tally across history, rank:
    ```
    git log --format='@%H' --name-only --since=<map-window> \
      | awk '/^@/{c=$0; next} NF{print c"\t"$0}' \
      | <group by commit; for each commit emit cross-component file pairs> \
      | sort | uniq -c | sort -rn | head
    ```
    The map's file→component table drives the "spans two components" test; the pairing step is a short script, not a one-liner.
  - **read it as** the single most decisive map-derived axis WHEN the history gate passes: require ~50+ commits over the scope in the window (`git rev-list --count`) — a squashed or freshly-imported history makes every pair co-change in one commit, turning the axis into uniform noise; below the gate, drop it rather than let garbage dominate. With real history: a candidate that draws boundaries so the heaviest co-change pairs fall INSIDE one component wins; a boundary cutting through a high-frequency pair predicts future cross-component churn. Compare candidates on total cross-boundary co-change weight.
  - **gaming risk** minimize trivially by lumping the whole repo into one component — always read alongside size distribution and cohesion so the "fix" isn't just erasing boundaries.

- **Dependency-graph shape** — cycle count, longest path (depth), layering violations. **compute by** JS/TS `madge --circular` for cycles and `madge --json` for the graph to derive longest path; also dependency-cruiser for rule-based layer checks (both verified real — madge has `--circular`/`--orphans`/`--json`, per https://github.com/pahen/madge; dependency-cruiser validates forbidden deps, cycles, orphans, per https://github.com/sverweij/dependency-cruiser, verified 2026-07-15). Elixir `mix xref graph` (and `--format dot` piped to graph tooling for shape). Rust cargo-modules to emit the module graph. **read it as** fewer cycles is unambiguously better (0 is the target); a shorter longest-path = flatter, more comprehensible layering; layering violations (a low layer importing a high one) are hard failures a good candidate has zero of. **gaming risk** cutting a cycle by hiding one edge behind dynamic dispatch/DI removes it from the static graph but not from reality.

- **Public-surface ratio = exports imported elsewhere ÷ total exports** per component.
  - **compute by** enumerate a component's exported symbols, then `git grep` each across OTHER components; ratio = referenced ÷ total.
  - **read it as** low ratio = dead surface = carrying cost and false coupling promises; a tight component exposes roughly what's used. A candidate that shrinks total public surface while keeping the used exports is cleaner.
  - **gaming risk** collapsing everything to one mega-export or re-exporting through a barrel file inflates apparent usage while widening the real blast radius.

- **Size distribution** — LOC per component and its variance.
  - **compute by** `git ls-files -- <component-glob> | xargs wc -l` per component; compare the distribution (median, spread, max/median ratio) across candidates.
  - **read it as** one giant + a swarm of tiny components suggests the boundaries landed wrong — the giant is under-decomposed, the tiny ones are arbitrary splits. Prefer a candidate with a tighter, more even spread. Absolutes vary by language; compare candidates to each other, not to a fixed LOC target.
  - **gaming risk** slicing a real component into equal-LOC fragments to flatten variance destroys cohesion — always pair with the cohesion axis.

- **Duplication across boundaries** — the same logic copy-pasted into multiple components is a missing shared component the design should surface.
  - **compute by** jscpd over the tree, bucketed by the map's component partition — it detects duplicated blocks via Rabin-Karp across 200+ formats and reports a duplication percentage (per https://github.com/kucherenko/jscpd, verified 2026-07-15). Clones whose two ends land in different components are the signal.
  - **read it as** high cross-component duplication = a candidate that failed to factor out a shared kernel; a design that pulls the duplicated block into one owned component beats one that leaves it smeared.
  - **gaming risk** a naïve extract-to-shared-util for incidental (not essential) duplication manufactures false coupling — only real, semantically-identical clones count.

## Fitness functions

Encode the CHOSEN design's rules as CI-run tests so the architecture can't silently rot (evolutionary architecture — Ford, Parsons & Kua, _Building Evolutionary Architectures_, O'Reilly). A rule that isn't executable is a comment; these must fail the build.

- **Forbidden-dependency tests** — assert the allowed dependency edges between components; any import crossing a disallowed boundary fails CI.
  - JS/TS — eslint-plugin-boundaries (`boundaries/dependencies` with an allow/disallow policy over element types — the current rule name; `element-types` and `entry-point` are deprecated aliases; per https://www.jsboundaries.dev/docs/rules/, verified 2026-07-15) or dependency-cruiser `forbidden` rules (per https://github.com/sverweij/dependency-cruiser, verified 2026-07-15) — pick one, don't run both.
  - Elixir — `mix xref graph` post-processed to assert no edge violates the layer order; there's no built-in allow-list flag (verified 2026-07-15 — xref exposes only exclude/label/source/sink/min-cycle-size/fail-above), so parse `--format dot`/plain output in a test and fail on any forbidden component→component edge.
  - Rust — cargo-deny `bans` denies specific crates/deps (per https://github.com/EmbarkStudios/cargo-deny, verified 2026-07-15); for intra-crate module boundaries it won't suffice — add a custom cargo-modules graph assertion.
  - Canonical prior art — ArchUnit (JVM) is the reference implementation of architecture-as-test; cite it when explaining the pattern even though this codebase isn't JVM.

- **Public-surface enforcement (deep-import bans)** — forbid reaching past a component's public entry into its internals.
  - **encode by** a dependency-cruiser `forbidden` rule or eslint-plugin-boundaries `boundaries/dependencies` with `fileInternalPath` (subsumes the deprecated `entry-point` rule; per https://www.jsboundaries.dev/docs/rules/, verified 2026-07-15) banning imports that resolve to a component's non-index/internal paths; enforce that cross-component imports hit only the declared entry point.
  - Keeps the public-surface ratio from silently reopening — without it, one convenient deep import reintroduces the coupling the design removed.

- **Cycle-freedom as a test** — wire the cycle check into CI as an assertion, not a report.
  - **encode by** `madge --circular <src>` exits non-zero on any cycle (JS/TS, per https://github.com/pahen/madge, verified 2026-07-15); dependency-cruiser has an equivalent no-circular rule; for Elixir/Rust assert zero back-edges from the xref/cargo-modules graph.
  - Target is exactly 0 — a single reintroduced cycle fails the build.

- **Churn watch** — after the rebuild, track where hotspots recur.
  - **compute by** periodically re-run the cross-boundary co-change procedure on post-rebuild history (same `git log` walk, restricted to commits since the rebuild landed).
  - **read it as** a hotspot recurring in the SAME component is normal maturation → hand to /gigarefine for polish; a hotspot recurring ACROSS component boundaries means the boundary is wrong → the design failed its core promise, escalate back into /gigaredesign.
  - This is the one fitness function that judges the architecture itself, not just conformance to it — the others check that code obeys the design; this checks whether the design was right.

## Using these

- Score all three candidates on the identical axes from the identical map data — same partition, same git window — so the comparison is apples-to-apples.
- Apply the skill's order-swap when judging: re-run the comparison with candidate order reversed and confirm the winner is stable, not an artifact of presentation order.
- Cross-boundary co-change (history gate passed) and cycle count are the highest-signal map-derived axes; let them dominate ties. With shallow history, cycle count and cohesion carry the tie alone.
- After the rebuild, the fitness functions ARE the design's regression suite — they run in CI on every change and fail the build when a boundary, surface, or cycle rule is violated.
- A design without executable rules regresses to vibes: the structure you shipped decays back toward the one you replaced within a few sprints, silently, because nothing was watching.
