# Worked examples — sequential-thinking

Two complete chains at Standard depth demonstrating the protocol in `../SKILL.md`.

> _Task: "Our nightly ETL job started taking 4 hours instead of 40 minutes. Figure out why."_

```
Thought 1/7 [frame]: Diagnosis-type. Success = identify the responsible
change. Known: started ~last week. Assumed (unverified): input volume
is stable. Restated without inherited suspects: "the job got 6x slower;
find the mechanism."

Thought 2/7 [decompose]: Differential: (a) data volume/shape changed,
(b) code or query changed, (c) infrastructure changed. Order by cost
to verify: (a) row counts, (b) git log, (c) change log.

Thought 3/7 [evidence]: Row counts flat, ±2% week over week. (a) pruned
— and the frame's assumption is now verified at rung 3, not assumed.

Thought 4/7 [evidence]: git log: one merge 8 days ago — "switch orders
join to include returns table."

Thought 5/7 [hypothesis]: New join lacks an index on returns.order_id,
forcing a scan per batch.
Kill condition: EXPLAIN shows an index scan on returns.

Thought 6/7 [challenge]: Ran the kill test — EXPLAIN shows seq scan,
40M rows, no index (rung 3). Hypothesis survives its own kill
condition. Negative space: if (c) infra were the cause, the change log
would show a deploy or instance event in the window — it shows none.
Pruned on absence of expected evidence, which I looked for, not just
failed to see.

Thought 7/7 [verdict]:
Verdict: the returns-table join added 8 days ago triggers a sequential
scan; add an index on returns.order_id.
Confidence: high (~90%) — mechanism confirmed at rung 3, rivals pruned
on direct evidence.
Would change my mind: prod having the index when staging doesn't.
Open questions: whether the join also needs a date filter as returns
grows.
```

The same spine handles decisions, compressed to show the shape:

> _Task: "Should we move our job queue from Redis to Postgres SKIP LOCKED?"_

```
Thought 1/6 [frame]: Decision-type, one-way-door-ish (migration is
costly to reverse) → Standard depth despite small system. Criteria:
ops simplicity (2-person team), throughput headroom, job durability.
Thought 2/6 [hypothesis]: A: stay on Redis. B: Postgres SKIP LOCKED
(kill: benchmarks under 2x measured peak). C: managed queue — added
so B isn't judged only against the incumbent.
Thought 3/6 [evidence]: Metrics show 11 jobs/s peak, not the 50 the
user cited (a growth guess — confirmed by asking, rung 3). SKIP
LOCKED benchmarks >1k jobs/s on this instance class. B's kill
condition not met.
Thought 4/6 [challenge]: Premortem on B: queue-table bloat under
churn; long transactions starving workers — documented, mitigable.
Premortem on A: persistence misconfig loses jobs; incident log shows
it already happened once.
Thought 5/6 [challenge]: Steelman C: least ops of all. Pruned on a
constraint, not a vibe: team explicitly avoids new cloud
dependencies (asked).
Thought 6/6 [verdict]:
Verdict: migrate to Postgres SKIP LOCKED.
Confidence: medium-high (~75%) — throughput verified; bloat
mitigation unverified on this workload. Mechanism certain, fix
partly a bet — saying both.
Would change my mind: projections showing sustained >500 jobs/s, or
heavy large-payload churn.
Open questions: autovacuum tuning for the queue table.
```
