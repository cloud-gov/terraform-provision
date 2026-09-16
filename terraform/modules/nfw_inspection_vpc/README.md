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
- `stateful_default_actions` is not set, so traffic matching no rule is passed
  (the AWS default under `STRICT_ORDER`).

The firewall therefore logs and alerts but does not drop. Promoting to
enforcement requires setting `firewall_rule_groups_count_only = false` and
`override_action_to_count = false` on each rule group, after reviewing ALERT
logs for the traffic that would have been dropped.

## Scope and Limitations

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
- **Logging covers FLOW and ALERT.** The `TLS` log type is not configured
  because it only produces records when a TLS inspection configuration is
  attached to the policy, and this module does not create one.
