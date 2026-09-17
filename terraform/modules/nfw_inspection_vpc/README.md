# AWS Network Firewall Inspection VPC

The module creates an inspection VPC but does not connect it to any spoke VPCs. This is left to the bosh_vpc module. The inspection VPC is only intended to inspect egress traffic. Egress includes east-west or egress from one VPC to another VPC.

According the AWS, ingress inspection typically is not in scope for the network firewall. WAF, security groups, and NACLs are the preferred method of securing ingress traffic.

## Traffic Flow

Egress from a spoke VPC:

```
spoke VPC -> TGW -> tgw subnet -> firewall endpoint -> firewall subnet -> NAT gateway -> public subnet -> IGW
```

Return traffic reverses the path. The firewall sits *before* the NAT gateway so
Suricata sees the real spoke source addresses rather than the NAT address, which
is what makes `HOME_NET` meaningful.

Each AZ gets its own firewall endpoint, route tables, NAT gateway, and EIP. The
TGW attachment uses `appliance_mode_support = "enable"` so both directions of a
flow pin to the same AZ; without it, asymmetric routing breaks stateful
inspection.

## Default Firewall Behavior

Given this will be applied to existing VPCs, the default firewall behavior is to not block anything.

Two settings produce this posture:

- `firewall_rule_groups_count_only` defaults to `true`, overriding every managed
  rule group to `DROP_TO_ALERT`.
- `stateful_default_actions` defaults to `[]`, so traffic matching no rule is
  passed (the AWS behavior under `STRICT_ORDER`).

The firewall therefore logs and alerts but does not drop. This is deliberate:
the module attaches to existing VPCs carrying live traffic, and a DROP default
risks blocking or locking out a running environment before anyone knows what
the rules would have matched.

### Promoting to Enforcement

Enforcement is a per-environment decision, made after ALERT logs show what
would have been dropped. The intended sequence:

1. Deploy with the defaults. Leave it alone long enough to build a traffic
   baseline across all attached spokes, including periodic and batch workloads.
2. Review the ALERT log group (`/aws/network-firewall/<name_prefix>/alert`) for
   matches. Every match is traffic that enforcement would drop.
3. Resolve each match: fix the workload, or exclude the rule group, or accept
   the drop.
4. Flip the cutover switch:

   ```hcl
   firewall_rule_groups_count_only  = false
   firewall_rule_groups_enforce_all = true
   ```

   `firewall_rule_groups_enforce_all` forces every rule group to DROP,
   overriding each group's own `override_action_to_count`. It exists so cutover
   is one reviewable flag per environment rather than a hand edit of every rule
   group. The two flags are mutually exclusive and validated as such.
5. Optionally fail closed on unmatched traffic by setting
   `stateful_default_actions`. This is a much larger blast radius than rule
   group enforcement -- it drops anything no rule explicitly passed -- so treat
   it as a separate change with its own baseline review.

To promote individual rule groups instead of all at once, leave both global
flags at their defaults and set `override_action_to_count = false` on the
specific groups in `firewall_managed_rule_groups`.

## Logging

The module produces two independent log streams, both to CloudWatch:

| Log | Group | Covers |
|---|---|---|
| Firewall FLOW / ALERT | `/aws/network-firewall/<name_prefix>/{flow,alert}` | Traffic that reached a firewall endpoint, and rule matches |
| VPC flow logs | `/aws/vpc-flow-log/<name_prefix>` | Every ENI in the VPC: TGW attachment, NAT gateways, firewall endpoints |

The two are not redundant. Firewall logs say nothing about the TGW, NAT, or IGW
hops, so traffic that never reaches an endpoint -- whether misrouted or
deliberately bypassing inspection -- leaves no firewall record. Since this VPC
is the single egress chokepoint for every attached spoke, VPC flow logs provide
the inspection-independent record of what actually crossed the boundary.

Both are controlled separately (`logging_enabled`, `flow_logs_enabled`) and
share `log_retention_days`, which defaults to 1096 days (3 years). That is the
repo-wide value: the lowest CloudWatch retention option that satisfies the
M-21-31 requirement to retain network telemetry for 30 months. Lowering it below
913 days puts the platform out of compliance with that requirement.

CloudWatch Logs accepts only a fixed set of retention periods, so
`log_retention_days` is validated against that set. Without the check, an
unaccepted value is not caught until apply -- after the firewall and log groups
are already being created.

VPC flow logs default to a 60-second aggregation interval rather than the AWS
default of 600. This is the platform egress boundary, so aggregation
granularity bounds how precisely an incident can be reconstructed; it is also
the value AWS requires if TGW-level flow logs are added later. The cost is
roughly 10x the record volume of 600s -- set
`flow_logs_aggregation_interval = 600` to trade precision for spend.

## Scope and Limitations

- **The default posture does not block traffic.** See Default Firewall Behavior
  above. Alert-only is intentional, not an oversight, and promoting to
  enforcement is a deliberate per-environment step.
- **Two AZs only.** `availability_zones` and the three subnet CIDR lists are
  validated to contain exactly two entries.
- **IPv4 only.** The VPC has no IPv6 CIDR and all default routes are
  `0.0.0.0/0`. IPv6 egress would bypass inspection entirely.
- **`internal_cidrs` must cover every attached spoke.** Return routes in the
  inspection VPC come from this variable. A spoke whose CIDR is missing has its
  return traffic fall through to `0.0.0.0/0` -> IGW and blackhole, with no error
  from either module.
- **The EIPs use `prevent_destroy`.** `terraform destroy` of this module will
  fail until the EIPs are removed from state deliberately. This protects egress
  addresses that downstream allowlists may depend on.
- **Firewall logging covers FLOW and ALERT.** The `TLS` log type is not
  configured because it only produces records when a TLS inspection
  configuration is attached to the policy, and this module does not create one.
- **Log groups use AWS-managed encryption.**
