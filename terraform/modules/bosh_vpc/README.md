# `bosh_vpc`

The VPC has: two public and two private subnets across two AZs, an internet gateway, per-AZ NAT gateways, S3 endpoints, shared security groups, and VPC flow logs.

## Egress through the inspection VPC

Egress through the inspection VPC requires multiple deployments to minimize downtime. If you skip a stage, there WILL BE EXTENDED DOWNTIME. Please read this doc before changing any values and applying. **Changes outside this module ARE REQUIRED.**

> NOTE: The inspection VPC, its AWS Network Firewall, and the transit gateway are owned by the `firewall-inspection-vpc` stack (`terraform/modules/nfw_inspection_vpc`). This module creates only the spoke-side half of the attachment and reads the inspection stack's outputs from its remote state.

### The Outage

Moving egress to the inspection VPC changes the source address external services see, from this VPC's NAT EIPs to the inspection VPC's EIPs. **Established outbound TCP connections reset, resulting in downtime.** No amount of dependency ordering prevents this; it is a reality of changing the egress path, not of how Terraform applies it.

### What does not break

Useful when scoping the maintenance window:

- **S3** `aws_vpc_endpoint.private-s3` is a gateway endpoint associated with both private route tables, and its prefix-list route is more specific than the default route. BOSH and Concourse blobstore traffic never touch the TGW.
- **Intra-VPC traffic** — it uses the local route. BOSH director to agent keeps working.
- **Inbound traffic.** The public route table keeps `0.0.0.0/0` on the internet gateway, so load balancers and the interface VPC endpoints are untouched.

### What stays in place

- **The NAT gateways and EIPs in this VPC.** They go idle but are not destroyed so rollback is possible.

- **The public route table's default route.** Stays on the internet gateway.

- **The private route resource names.** The `az1_nat_service_route` and `az2_nat_service_route` names do not change. A change would cause Terraform to destroy and recreate them.

### Private network egress traffic flows

No Firewall (existing) - `egress_traffic_through_inspection_vpc = false`:

```
private subnet -> NAT gateway (this VPC) -> IGW (this VPC)
```

Through Inspection VPC & Firewall - `egress_traffic_through_inspection_vpc = true`:

```
private subnet -> TGW -> inspection VPC -> firewall -> NAT gateway -> IGW
                                                       (inspection VPC)
```

### Public Network Egress Traffic flows

Public subnets continue to send `0.0.0.0/0` through the existing internet gateways. Only destinations listed in `inspection_internal_cidrs` are routed from the public subnets over the TGW.

### Moving Egress Traffic through the Inspection VPC

Be sure you read this carefully and completely before proceeding. The dragons lie in wait...

#### Inputs

| Variable | Required when attached | Notes |
|---|---|---|
| `attach_to_inspection_vpc` | — | Phase one. Defaults to `false`. |
| `egress_traffic_through_inspection_vpc` | — | Phase two. Defaults to `false`. Implies phase one. |
| `remote_state_bucket` | Yes | Bucket holding the `firewall-inspection-vpc` stack's state. |
| `remote_state_key` | No | Defaults to `firewall-inspection-vpc/terraform.tfstate`. |
| `tgw_subnet_cidrs` | Yes | Two CIDRs, `[az1, az2]`, inside `vpc_cidr`, not overlapping any existing subnet. `/28` is enough. |
| `inspection_internal_cidrs` | No | Destinations the *public* subnets should reach over the TGW. Empty routes nothing from the public subnets. |

> `tgw_subnet_cidrs` and `remote_state_bucket` are required by `precondition` blocks rather than by variable validations, because a variable validation cannot read another variable and these are only required once the VPC is attached.

#### Phase 0 - Add this VPC's CIDR to the Inspection VPC

Add this VPC's CIDR range to the `internal_cidrs` variable in the `firewall-inspection-vpc` stack and apply that stack. If the value already contains ranges covering this VPC's CIDR, no change is needed.

The `firewall-inspection-vpc` stack generates, per AZ, a route from its firewall subnet back to the TGW and a route from its NAT subnet back to the firewall endpoint, for each CIDR in `internal_cidrs`. The routes it creates are inert until a spoke attaches. It also builds the firewall's `HOME_NET` ip_set from the same list, so a missing CIDR silently changes the meaning of every `$HOME_NET` Suricata rule.

> Pro Tip: A spoke missing from that list gets a working forward path and a return path that blackholes, **with no error from either module**. That is the failure mode to check first if traffic stops.

#### Phase 1 — attach, move nothing

Set `attach_to_inspection_vpc = true` & apply. This creates the TGW subnets, the attachment, this spoke's TGW route table, its default route to the inspection attachment, and the return propagation. Routing in this VPC is untouched; the bosh_vpc traffic still egresses via the NAT gateways.

Then verify, with no traffic at risk:

1. The VPC attachment reports state `available`.
2. **WAIT UNTIL this VPC's CIDR appears in the inspection VPC's TGW route table.** Propagation converges some time *after* the AWS API returns and Terraform cannot see it. "Apply succeeded" is not "traffic will work."
3. The firewall endpoints are healthy.
4. Read `inspection_nat_egress_ips` and **insert those addresses into every external allow list** that currently names `nat_egress_ip_az1`/`az2`. _The allowlist locations may be stack dependent and may be shared. Use caution._.

> Note: I recommend leaving the old nat gateway EIPs (from this VPC) in the allow list in case rollback is necessary. If you chose to ignore this, use caution on rollback.

Phase one is idempotent and reversible, and can sit in this state indefinitely. But where is the fun in that?

##### Why?

`aws_ec2_transit_gateway_route_table_propagation` — the resource that teaches the inspection side how to reach this VPC — is created *here*, not in the inspection stack, and cannot be moved there:

1. It requires `transit_gateway_attachment_id`, which AWS generates when the spoke attachment is created. There is nothing to reference beforehand.
2. The attachment ID lives in this stack's state, while this stack already reads the inspection stack's state for `transit_gateway_id`. The reverse read would deadlock two separately-applied stacks — neither could be applied first. Think chickens and eggs...

This is an ordering constraint in the AWS data model, not a design choice.


#### Phase 2 — move traffic

**This is the step with impact**. _Did you update allow lists in other stacks?_ _Is this VPC's CIDR in the inspection VPC's TGW route table?_

Set `egress_traffic_through_inspection_vpc = true` and apply. The two private default routes switch targets from the bosh_vpc NAT gateways to the transit gateway.

> NOTE: Existing NAT Gateways in the bosh_vpc intentionally are NOT deleted. Deleting the NAT Gateways and associated EIPs is not recoverable, and rollback would be costly. This can be reevaluated after some time of stability.

#### Outputs

| Output | Meaning |
|---|---|
| `inspection_attached` | The attachment exists. True in phase 1 & 2. |
| `inspection_enabled` | Egress is actually through the firewall via the TGW. False during phase one. |
| `inspection_tgw_subnets` | TGW attachment subnet IDs, or `[]`. |
| `inspection_tgw_attachment_id` | This VPC's attachment ID, or `null`. |
| `inspection_tgw_route_table_id` | This spoke's own TGW route table ID, or `null`. |
| `inspection_nat_egress_ips` | The inspection VPC's NAT EIPs. Populated from phase one onward. |

### Rollbacks

The order of operations for rollback is important to prevent long downtime. Dependencies outside this repository can be rolled back as well, depending on your goal. As with deployment, it is important to understand the entire process and dependencies outside this module.

#### Rollback from phase 2

> WARNING: If you removed the NAT Gateway EIPs (from this VPC) from the allow list, you need to add them back before proceeding.

Set `egress_traffic_through_inspection_vpc = false`, keep `attach_to_inspection_vpc = true` and apply. The private routes return to the NAT gateways, which still exist with their original EIPs (provided you didn't delete them). External allow lists that still name the bosh_vpc NGW EIPs start working again.

#### Rollback from phase 1

If you need to roll back ONLY from phase 1 (phase 2 was never applied), set `attach_to_inspection_vpc = false`. This **destroys** the attachment, the TGW subnets, and this spoke's TGW route table. If you need to rollback after phase 2 was applied, be sure to execute the instructions under "Rollback from phase 2" first.

#### Rollback from phase 0

Use caution when removing this VPC's CIDR from the `internal_cidrs` variable in the `firewall-inspection-vpc` stack and applying it. This value covers all CIDR ranges for all spoke VPCs. A range may cover multiple VPCs.

## Scope and limitations

- **Private egress only.** The public subnets' default route stays on the internet gateway, so inbound internet traffic to public load balancers and to the interface VPC endpoints keeps a return path. East-west traffic *originating* in a public subnet is inspected only for the destinations enumerated in `inspection_internal_cidrs`.

- **IPv6 is not inspected.** The private subnets have no IPv6 CIDR.

- **S3 bypasses the firewall.** Routing S3 over the TGW would be a significant data-transfer cost and would put bulk traffic through the inspection path.

- **The spoke TGW route table holds only a default route.** Spokes cannot reach each other directly across the transit gateway; all east-west traffic goes through the firewall.
