# Experiment 1: single rule change

## Intended policy
Client may reach app:8080 only. Management zone is unreachable from client.

## Baseline observed
- client -> app:8080:  REACHABLE
- client -> mgmt:9000: BLOCKED

## Change made
Replaced the accept rule with one matching `ip daddr 10.0.0.0/16` and
`tcp dport { 8080, 9000 }` (file: lab/mutations/m001-widen-daddr.nft).

## Observed after change
- client -> app:8080:  REACHABLE
- client -> mgmt:9000: REACHABLE

## Reflection
Does the written policy still hold? 

No, the written policy no longer holds. The intended policy allowed only
client -> app:8080, but after one rule change the client could also reach
mgmt:9000. The baseline matched the policy (app reachable, mgmt blocked),
so the exposure was caused by the change alone.

A rule-by-rule review would probably catch this particular mutation, because
the management port (9000) appears explicitly in the rule. It is a useful
baseline, but not a subtle case. The harder cases are changes where each rule
looks harmless on its own: an overlapping subnet, a rule-ordering change, a
new route, or a NAT mapping. Those are the mutations this project should
focus on, since they are the ones configuration-level reasoning should find
and manual review is likely to miss.

Next step: build subtler mutations (m002 onward) and check whether the
reachability model predicts the exposure before the lab confirms it.
