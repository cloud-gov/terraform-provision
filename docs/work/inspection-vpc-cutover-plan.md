# Inspection VPC cutover — work plan and status

**Branch:** `firewall-inspection-vpc`
**Base commit at session start:** `8004564e` ("rename owner")
**Last updated:** 2026-10-02
**Status:** in progress — items 1-4 implemented in the working tree, not committed

**To resume:** read this file, check `git status` against the "Git state" table
below, then continue from "Remaining work".

---

## Goal

Let `terraform/modules/bosh_vpc` optionally route egress through the network
firewall inspection VPC deployed by `terraform/stacks/firewall-inspection-vpc`
(module `terraform/modules/nfw_inspection_vpc`), controlled by a variable, with a
**staged cutover** so the transit gateway path can be verified before production
traffic moves onto it.

## Standing constraints from the requester

These were given across the session and still apply. Do not relax them without
asking.

- Change **`terraform/modules/bosh_vpc`** (primary), plus
  **`terraform/modules/stack/base`** and **`terraform/stacks/tooling`** as the
  callers.
- **Do not change `terraform/stacks/main`.** Explicitly excluded.
- **Do not change `terraform/modules/nfw_inspection_vpc` or
  `terraform/stacks/firewall-inspection-vpc`** — with one approved exception: the
  NAT EIP `prevent_destroy` change, which the requester asked for by name.
  Anything else in those two paths must be *suggested*, not applied.
- **Do not read vars files** (`*.tfvars`). **Do not read CI files** — the
  requester is handling pipeline changes.
- **Do not commit.** Stage each logical commit and output a commit message for
  the requester to edit, commit, and push.

## Environment limitation (affects every claim in this document)

**No `terraform` or `tofu` binary is available in this environment.** Nothing has
been `terraform fmt`-checked, `validate`d, or `plan`ned. What *was* checked, by
script:

- `terraform fmt` attribute alignment (single-space-after-longest-key per block)
- tabs, trailing whitespace, EOF newline
- brace/bracket/paren balance outside strings and comments
- cross-module wiring: every `var.X` referenced exists; every argument passed is
  declared by the callee; every `module.X.Y` output reference exists

Everything else in this document is a static reading of the configuration. See
"Verification checklist" for what a human must run.

---

## Git state

Three logical commits. Only one can occupy the index at a time.

| # | Scope | Files | Status |
|---|---|---|---|
| 1 | `bosh_vpc` | `README.md`, `network_private.tf`, `network_public.tf`, `nfw_inspection.tf`, `outputs.tf`, `variables.tf`, `versions.tf` | **staged** (amended with items 1, 2, 4) |
| 2 | `nfw_inspection_vpc` EIP | `inspection_vpc.tf` | unstaged, complete |
| 3 | callers | `stack/base/{base,outputs,variables}.tf`, `stacks/tooling/{stack,outputs,variables}.tf` | unstaged, complete |

Stage 2 with:

```
git add terraform/modules/nfw_inspection_vpc/inspection_vpc.tf
```

Stage 3 with:

```
git add terraform/modules/stack/base terraform/stacks/tooling
```

**Unrelated working-tree changes — leave alone.** These were present before this
work and are not part of it: `.gitignore`, `terraform/stacks/dns/*`, and the
untracked `docs/prompts/`, `docs/review/`, `terraform/modules/nfw_temp/`,
`terraform/modules/network-firewall-inspection-vpc/`.

---

## Design decisions on record

Each was chosen deliberately; the rationale matters if someone revisits them.

| Decision | Choice | Why |
|---|---|---|
| How `bosh_vpc` learns the TGW ids | `terraform_remote_state` **inside** the module, with `count` on the flag | Requester's choice over explicit input variables. The `count` is load-bearing: an ungated data source would make every consumer fail to plan until the inspection stack's state object existed. |
| Public route table when enabled | Keeps `0.0.0.0/0` on the IGW; adds per-CIDR TGW routes from `inspection_internal_cidrs` | Inbound internet traffic to public load balancers must return via the IGW. Moving the default route breaks every inbound connection. |
| Public TGW routes form | Inline `dynamic "route"` block, not separate `aws_route` resources | A route table with inline `route` blocks is authoritative — the provider deletes undeclared routes. Mixing forms would add and remove the TGW routes on alternating applies. |
| Spoke NAT gateways and EIPs when enabled | Kept, idle | `aws_eip` has `prevent_destroy = true` and no variable can override a lifecycle block, so removal is impossible without editing the module. Also keeps `nat_egress_ip_az1/az2` populated and makes rollback reversible without reallocating addresses. Cost: two idle NAT gateways per environment. |
| Phase-1 variable name | `attach_to_inspection_vpc` | Requester's choice. |
| Rollback documentation | Both phases | Requester's choice. |
| TGW subnet CIDRs in tooling | `cidrsubnet(var.vpc_cidr, 12, 48)` / `(…, 49)` | Derived like every other subnet in that stack rather than hardcoded, so values track `vpc_cidr`. |

---

## Completed work

### Commit 1 — `terraform/modules/bosh_vpc`

**`nfw_inspection.tf`** (new file). All resources gated. Creates, when attached:

- `data.terraform_remote_state.firewall_inspection_vpc` — `count`-gated; two
  preconditions for `remote_state_bucket` / `remote_state_key`
- `aws_subnet.tgw` ×2 — TGW attachment ENI subnets, one per AZ; precondition
  requiring `tgw_subnet_cidrs`
- `aws_route_table.tgw` + 2 associations — local route only
- `aws_ec2_transit_gateway_vpc_attachment.main_vpc` — default RT association and
  propagation both `false`, matching the inspection VPC's TGW
- `aws_ec2_transit_gateway_route_table.main_vpc` — this spoke's own TGW route
  table, separate from the inspection VPC's so spokes cannot reach each other
  directly across the TGW
- `aws_ec2_transit_gateway_route_table_association.main_vpc`
- `aws_ec2_transit_gateway_route.main_vpc_egress_to_inspection` — `0.0.0.0/0` to
  the inspection attachment; this is what forces traffic through the firewall
- `aws_ec2_transit_gateway_route_table_propagation.main_vpc_to_inspection` —
  return path across the TGW hop

TGW ids are resolved once in `locals` via `one(data...[*].outputs.X)`. Not via
`try()` — `try()` would also swallow a genuinely renamed output, turning it into
a silent `null` that surfaces as a route with no target at apply.

**`variables.tf`** — added `egress_traffic_through_inspection_vpc`,
`attach_to_inspection_vpc`, `remote_state_bucket`, `remote_state_key`,
`tgw_subnet_cidrs`, `inspection_internal_cidrs`, with validations.

**`network_private.tf`** — the two private default routes switch target between
NAT gateway and TGW. **Resource names deliberately unchanged** (`az1_nat_service_route`,
`az2_nat_service_route`): renaming changes their state addresses, which would make
Terraform destroy and recreate the default route of a live VPC.

**`network_public.tf`** — `inspection_internal_cidrs` routes via inline dynamic
block; IGW default route untouched.

**`outputs.tf`** — `inspection_enabled`, `inspection_attached`,
`inspection_tgw_subnets`, `inspection_tgw_attachment_id`,
`inspection_tgw_route_table_id`, `inspection_nat_egress_ips`. Note added to
`nat_egress_ip_az1/az2` warning they no longer describe the live path once
inspection is enabled.

**`versions.tf`** — `required_version` `>= 0.15` → `>= 1.2.0` for `precondition`
blocks.

**`README.md`** (new) — traffic flow, inputs, the `internal_cidrs` contract,
staged cutover runbook, rollback, scope and limitations, verification.

### Commit 2 — `nfw_inspection_vpc` NAT EIP protection

`inspection_vpc.tf:60` — `prevent_destroy` `false` → `true`, with comment.

Reverses `111ce3e9`, which set it false after `47673acd` found a lifecycle block
cannot take a variable. That constraint still holds, so this is not switchable per
environment: `terraform destroy` of the module now fails until the EIPs are
removed from state deliberately. Already documented in that module's README.

Rationale: once a spoke enables inspection, these EIPs are the platform's actual
egress addresses, and the spoke EIPs that still carry `prevent_destroy` are the
idle ones. Protection was on the wrong side of the pair.

### Commit 3 — callers

`modules/stack/base` — declares and passes `remote_state_key`,
`tgw_subnet_cidrs`, `inspection_internal_cidrs`, `attach_to_inspection_vpc`;
re-exports all six inspection outputs.

`stacks/tooling` — declares `inspection_internal_cidrs` and
`attach_to_inspection_vpc`; derives `tgw_subnet_cidrs` from `vpc_cidr`;
re-exports the outputs.

Every new variable defaults to the pre-inspection behavior, so no new required
input and no plan change until a flag is set.

---

## Remaining work

Items 1-4 are implemented in the working tree. What remains is **human
verification** — see the checklist below. Nothing further is blocked on an agent.

If this document is being read after an interruption and the working tree does
*not* match the Git state table, the items were:

### Item 1 — ordering bugfix (required)

`network_private.tf` and `network_public.tf` originally depended only on
`aws_ec2_transit_gateway_vpc_attachment.main_vpc`, not on the route table
association, the spoke default route, or the propagation. Terraform was therefore
free to flip the VPC default route to the TGW before any of those existed:
traffic arrives at a TGW with no onward route and no return route, and
blackholes.

Fix: all three `depends_on` lists name the attachment, the association, the spoke
TGW route, and the propagation.

**Limit, stated plainly:** this orders Terraform's API calls. It does **not** wait
for TGW route propagation to converge, which happens after the API returns. A
single-phase apply therefore retains a window Terraform cannot see. That is the
argument for item 2.

### Item 2 — `attach_to_inspection_vpc`

```hcl
inspection_attached = var.attach_to_inspection_vpc || var.egress_traffic_through_inspection_vpc
```

Eight resources moved from `inspection_enabled` to `inspection_attached` (the
remote state read, both TGW subnets, the TGW route table and its associations,
the VPC attachment, the spoke TGW route table, its association, the spoke default
route, and the propagation).

The route *targets* stay on `inspection_enabled` — that is the traffic move and
the whole point of the split.

The `||` makes **egress ⇒ attached** structural, so no precondition is needed to
enforce it. An earlier version of this plan proposed one; it would have been dead
code.

Side effect worth keeping: gating the remote-state read on `inspection_attached`
populates `inspection_nat_egress_ips` during phase 1, which is when external
allowlist coordination has to happen.

### Item 3 — plumb through

Six files across `modules/stack/base` and `stacks/tooling`. `stacks/main`
untouched per constraint.

### Item 4 — README

Staged runbook, rollback for both phases, inputs row, fourth plan case, and the
downtime correction below.

---

## Corrections to earlier claims

Recorded so they are not reintroduced.

**The README understated cutover impact.** An earlier draft said the interruption
is "confined to the moment the route target changes." When egress moves from this
VPC's NAT gateway to the inspection VPC's, **established outbound TCP connections
break**, because the remote end starts seeing a different source address. No
ordering fix changes that. The honest claim: two-phase converts an *unbounded*
outage from unconverged TGW routing into a *short, predictable* one from
connection resets. **Not zero downtime.** Schedule it.

**TGW propagation cannot be pre-set from the inspection VPC side.** The requester
asked whether managing the propagation via variables in `nfw_inspection_vpc` would
avoid downtime. It cannot, for two independent reasons:

1. `aws_ec2_transit_gateway_route_table_propagation` requires
   `transit_gateway_attachment_id`, which AWS generates when the spoke attachment
   is created. There is nothing to reference beforehand. Static
   `aws_ec2_transit_gateway_route` has the same required argument.
2. That attachment id lives in **tooling's** state, while tooling already reads
   the inspection stack's state for `transit_gateway_id`. The reverse read would
   deadlock two separately-applied stacks — neither could be applied first.

This is an ordering constraint in the AWS data model, not a design choice. The
requester's underlying goal is met instead by the two-phase flag.

What *can* be pre-set, and should be: `internal_cidrs` in the inspection stack.
See open risks.

---

## Cutover runbook

**Phase 1 — attach without moving traffic.** Set
`attach_to_inspection_vpc = true`, leave `egress_traffic_through_inspection_vpc`
false. Apply. Then verify, at leisure, with no traffic at risk:

1. The VPC attachment reports state `available`.
2. This VPC's CIDR appears in the inspection VPC's TGW route table (propagation
   has converged — this is the step that is invisible to Terraform).
3. The firewall endpoints are healthy.
4. Read `inspection_nat_egress_ips` and get those addresses into every external
   allowlist that currently names `nat_egress_ip_az1/az2`.

**Phase 2 — move traffic.** Add
`egress_traffic_through_inspection_vpc = true`. Apply. Private default routes
switch from the NAT gateways to the TGW. This is the only step with impact, and
it resets established outbound TCP connections.

**Rollback, phase 2.** Unset `egress_traffic_through_inspection_vpc`, keep
`attach_to_inspection_vpc`. Routes return to the NAT gateways, which still exist
with their original EIPs. Another round of connection resets; no address
re-coordination.

**Rollback, phase 1.** Unset both. Destroys the attachment and the TGW subnets.
Check first whether any other spoke's return path has come to depend on this
attachment being present.

### Mitigators that shrink the blast radius

Worth knowing before scheduling:

- **S3 is unaffected.** `aws_vpc_endpoint.private-s3` is a gateway endpoint on
  both private route tables; its prefix-list route is more specific than the
  default route. BOSH and Concourse blobstore traffic never touches the TGW.
- **Intra-VPC traffic is unaffected** — local route. BOSH director to agent keeps
  working.
- **Inbound to the main load balancer is unaffected** — the public default route
  stays on the IGW.
- **The firewall defaults to alert-only** (`firewall_rule_groups_count_only =
  true`, `stateful_default_actions = []`), so cutover risk is routing only. The
  firewall will not drop traffic it sees.

---

## Open risks for the human

Ordered by how likely they are to bite.

**1. `firewall-inspection-vpc` needs this VPC's CIDR in `internal_cidrs`.** This
is a **tfvars value change, not a `.tf` edit** — in
`terraform/stacks/firewall-inspection-vpc/vars.tfvars` or the pipeline's
`TF_VAR_internal_cidrs`. It can and should be set *before* phase 1; the routes it
creates are inert until a spoke attaches.

Three consumers in `nfw_inspection_vpc` depend on it:

| Consumer | Effect if the CIDR is absent |
|---|---|
| `aws_route.firewall_internal` (`inspection_vpc.tf:93`) | No route from the firewall subnet back to the TGW |
| `aws_route.public_return_to_firewall` (`inspection_vpc.tf:148`) | No route from the NAT subnet back to the firewall endpoint |
| `HOME_NET` ip_set (`firewall.tf:64`) | Suricata does not treat this traffic as internal, so every `$HOME_NET` rule silently changes meaning |

The first two are the blackhole: forward path succeeds, return path drops, **no
error from either module**. This is the first thing to check if traffic stops
after phase 2.

**Unverified** — vars files were not read per the constraints. If `internal_cidrs`
already contains an aggregate supernet (e.g. `10.0.0.0/8`) covering tooling's
`vpc_cidr`, **no change is needed at all**; the module's variable description
supports that. Check the current value first. Whatever is added must not equal or
be a subnet of `inspection_vpc_cidr` (module validation rejects it) and must not
duplicate an existing entry.

**2. `stacks/main` appears unable to validate today, independent of this work.**
`modules/stack/base` declares `remote_state_bucket` with no default (added in
`31161862`), but `modules/stack/spoke` — which is `stacks/main`'s only path into
`base` — neither passes nor declares it. That is a missing required argument.
Pre-existing; confirm it reproduces on `main` before attributing it to these
changes. Not fixed here because `stacks/main` is out of scope.

**3. The tooling TGW subnet CIDRs are inferred, not verified.**
`cidrsubnet(var.vpc_cidr, 12, 48)` and `(…, 49)` yield `10.0.3.0/28` and
`10.0.3.16/28` for a `/16` VPC — third octet 3. "Third octet 3 is free" was
derived by enumerating `cidrsubnet` calls in `.tf` files only. Subnets allocated
in BOSH manifests, by hand, or in vars files would not appear in that analysis.
Check the live route tables before applying phase 1.

**4. The public route table will show as modified on the first apply even with
both flags false.** The `dynamic "route"` block means Terraform now manages
routes in that table it previously only declared. This *should* be a no-op diff.
It is the single claim in this change least supported by evidence, and the one
most worth confirming with a real plan.

---

## Verification checklist (human, before merge)

1. `terraform fmt -check` and `validate.sh` via the repository's own PR checks.
2. Plan with **both flags false** against an existing environment → expect **no
   changes**. This is the central claim of the gating and the one most worth
   trying to falsify.
3. Plan with **`attach_to_inspection_vpc` only** → expect TGW subnets,
   attachment, route tables, association, route, propagation; **no route target
   changes** in the private or public route tables.
4. Plan with **both flags true** → expect the two private route target changes,
   and the public route table untouched when `inspection_internal_cidrs` is
   empty.
5. Plan with **`attach_to_inspection_vpc` true and `tgw_subnet_cidrs` unset** →
   expect the precondition message naming the missing input, not an
   index-out-of-range error.

Item 1 (the `depends_on` fix) is a claim about Terraform's dependency graph that
case 3 or 4 would settle cheaply. It is the highest-value single check here.

---

## Suggested follow-ups, not implemented

Out of scope per the constraints; recorded so they are not lost.

- **`nfw_inspection_vpc.internal_cidrs` is a hand-maintained flat list** applied
  in both AZs, so it cannot express "this spoke's CIDR." Every spoke added
  requires editing the inspection stack. Worth considering whether it should be
  derived from attachment propagation instead.
- **`stacks/main` is not wired** for inspection. `modules/stack/spoke` does not
  pass the inspection variables through to `base`. Doing so would also require
  resolving risk 2 above.
