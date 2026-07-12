# diff_events.jq — turn two dashboard snapshots into notification events.
# Invoked as: jq -cn --argjson old ... --argjson new ... -f diff_events.jq
# Output: JSON array of {ts, repo, type, severity, title, url}

def ev($repo; $type; $sev; $title; $url):
  {ts: (now | todate), repo: $repo, type: $type, severity: $sev,
   title: $title, url: $url};

def failing($ci): $ci == "FAILURE" or $ci == "ERROR";

# Events for one of the user's own PRs present in both snapshots.
def mine_pair($key; $o; $n):
  [
    (if failing($n.ci) and (failing($o.ci) | not)
     then ev($n.repo; "ci_failed"; "high";
             "\($key) \"\($n.title)\" — CI is now failing"; $n.url) else empty end),
    (if $n.ci == "SUCCESS" and failing($o.ci)
     then ev($n.repo; "ci_green"; "info";
             "\($key) \"\($n.title)\" — CI is green again"; $n.url) else empty end),
    (if $n.review == "APPROVED" and $o.review != "APPROVED"
     then ev($n.repo; "approved"; "high";
             "\($key) \"\($n.title)\" — approved"; $n.url) else empty end),
    (if $n.review == "CHANGES_REQUESTED" and $o.review != "CHANGES_REQUESTED"
     then ev($n.repo; "changes_requested"; "high";
             "\($key) \"\($n.title)\" — changes requested"; $n.url) else empty end),
    (if $n.mergeable == "CONFLICTING" and $o.mergeable != "CONFLICTING"
     then ev($n.repo; "merge_conflict"; "high";
             "\($key) \"\($n.title)\" — now has merge conflicts"; $n.url) else empty end),
    (if ($n.nyr // 0) > ($o.nyr // 0)
     then ev($n.repo; "new_review_comments"; "high";
             "\($key) \"\($n.title)\" — \(($n.nyr // 0) - ($o.nyr // 0)) new review comment(s) awaiting your reply";
             $n.url) else empty end)
  ];

(
  [ $new.mine | to_entries[] | .key as $k | .value as $n
    | if $old.mine[$k] == null
      then ev($n.repo; "own_pr_tracked"; "info";
              "Now tracking your PR \($k) \"\($n.title)\""; $n.url)
      else mine_pair($k; $old.mine[$k]; $n)[]
      end ]
+ [ $old.mine | to_entries[] | .key as $k | .value as $o
    | select($new.mine[$k] == null)
    | ev($o.repo; "pr_disappeared"; "high";
         "\($k) \"\($o.title)\" — no longer open"; $o.url) ]
+ [ $new.rr | to_entries[] | .key as $k | .value as $n
    | select($old.rr[$k] == null)
    | ev($n.repo; "review_requested"; "high";
         "Review requested: \($k) \"\($n.title)\" by @\($n.author)\(if $n.draft then " (draft)" else "" end)";
         $n.url) ]
+ [ $old.rr | to_entries[] | .key as $k | .value as $o
    | select($new.rr[$k] == null)
    | ev($o.repo; "review_request_cleared"; "info";
         "Review request cleared: \($k) \"\($o.title)\""; $o.url) ]
+ [ $new.issues | to_entries[] | .key as $k | .value as $n
    | select($old.issues[$k] == null)
    | ev($n.repo; "issue_assigned"; "high";
         "Issue assigned to you: \($k) \"\($n.title)\""; $n.url) ]
)
