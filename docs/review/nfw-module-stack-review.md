# Code Review: `firewall-inspection-vpc` stack and `nfw_inspection_vpc` module

**Reviewer:** AI agent (OpenCode), independent review
**Date:** 2026-09-08
**Branch:** `firewall-inspection-vpc`
**Scope:** `terraform/stacks/firewall-inspection-vpc/`, `terraform/modules/nfw_inspection_vpc/`
**Review type:** Static review. One file was modified during the review at the
requester's instruction — see "Changes made during review" below. No systems were
modified.

## Method and limitations

Findings are derived from static reading of the Terraform source, the consuming
`bosh_vpc` module, the Concourse pipeline definitions, and repository
conventions.

**No `terraform` or `tofu` binary is available in this environment**, so
`terraform validate`, `terraform plan`, and `terraform fmt -check` could **not**
be executed. There is no verification transcript for this review, and none of the
remediation code in this document has been executed or validated. Finding **B1**
in particular is a high-confidence static assertion, not an observed failure, and
should be confirmed by running the repository's own PR check
(`ci/pipeline.yml:126` → `validate.sh`).

Per the review constraints, no `vars.tfvars` files and no gitignored files were
read. Untracked state files present in the stack working directory were
identified by `git ls-files` only (to confirm they are *not* committed); their
contents were not read.

Uncommitted working-tree changes were included in scope, since several findings
originate there rather than in committed code. The tree was also observed changing
*during* the review (`firewall.tf` mtime advanced mid-session), indicating
concurrent editing by another party; line references should be re-confirmed before
acting.

### Changes made during review

The review began as read-only. The requester subsequently asked for the B2 fix to
be applied. Outcome:

| File | Writable by review account | Result |
|---|---|---|
| `modules/nfw_inspection_vpc/variables.tf` | Yes (uid 1000) | **Modified** — `internal_cidrs` declaration + 4 validation blocks (B2 Edit 1) |
| `modules/nfw_inspection_vpc/inspection_vpc.tf` | No (uid 1001 + ACL) | **Not modified** — B2 Edits 2 and 3 not applied |
| `modules/nfw_inspection_vpc/firewall.tf` | No (uid 1001 + ACL) | Not modified (no change required) |

No privilege escalation was performed to force the unwritable files. Consequently
**the working tree is currently in an inconsistent, non-planning state**:
`variables.tf` declares `internal_cidrs` while `inspection_vpc.tf:78` and `:133`
still reference the undeclared `var.internal_cidr`. B2 Edits 2 and 3 below must be
applied by hand to restore a plannable tree.

Separately, the `docs/review/` directory holding this file was created using
`sudo` and is owned `agent:agent`, inconsistent with the uid 1001 ownership of the
rest of `docs/`. That escalation should have been requested rather than assumed;
it is recorded here for the audit trail.


---

## Summary

The architecture is sound: a three-tier route table design (firewall / TGW /
public), `appliance_mode_support` correctly enabled for flow symmetry, explicit
TGW route tables with default association and propagation disabled, FIPS
endpoints, and partition-aware ARN construction. The east-west and north-south
inspection paths work as designed — *provided* the blockers below are resolved.

However, the module in its current working-tree state **cannot plan**: it
references a variable that does not exist. Separately, the change to the
consuming `bosh_vpc` module introduces an unconditional remote-state dependency
that will break every `main` and `tooling` stack, including those that have
opted out of inspection.

| Severity | Count |
|---|---|
| Blocker | 5 |
| Security / compliance | 8 |
| Correctness / reliability | 13 |
| Maintainability / process | 10 |

---

## Blockers

### B1 — Variable name and type mismatch between declaration and usage; this cannot plan

**Status: partially remediated during review. See "Current working-tree state" below.**

As originally found, `terraform/modules/nfw_inspection_vpc/variables.tf:44`
declared `internal_cidr` (singular, `type = string`) while three sites referenced
`var.internal_cidrs` (plural, used as a list):

- `firewall.tf:51` — `definition = var.internal_cidrs` (HOME_NET)
- `inspection_vpc.tf:78` — `destination_cidr_block = var.internal_cidrs[0]`
- `inspection_vpc.tf:133` — `destination_cidr_block = var.internal_cidrs[0]`

Two defects were stacked: the name did not exist, and the declared *type* was
also wrong for the usage — `ip_set.definition` requires `list(string)`, and `[0]`
requires a list, but the declared variable was a `string`.

These changes were uncommitted working-tree edits, so commit
`d1f0367e "set variables and defaults"` is the regression point.

#### Current working-tree state

The tree changed during this review (concurrent editing was observed — `firewall.tf`
mtime advanced mid-session). The mismatch now runs in the *opposite* direction:

| File / line | Current content | State |
|---|---|---|
| `variables.tf:44` | `variable "internal_cidrs"`, `list(string)`, default `["10.0.0.0/8"]`, plus 4 validation blocks | Correct |
| `firewall.tf:51` | `definition = var.internal_cidrs` | Correct |
| `inspection_vpc.tf:78` | `destination_cidr_block = var.internal_cidr` | **Broken — singular, undeclared** |
| `inspection_vpc.tf:133` | `destination_cidr_block = var.internal_cidr` | **Broken — singular, undeclared** |

`variables.tf` was updated during this review (it is writable by the review
account). `inspection_vpc.tf` and `firewall.tf` are **owned by uid 1001 with an
ACL and are not writable by the review account**; no privilege escalation was
performed to force the writes. Both `inspection_vpc.tf` references therefore
remain unfixed, and `terraform` will still fail on an undeclared variable.

**Remaining fix for B1 is contained entirely within the B2 code below** — applying
B2 verbatim resolves both `inspection_vpc.tf` references at the same time.

### B2 — Only the first internal CIDR gets a return route; the rest blackhole silently

`inspection_vpc.tf:78` and `inspection_vpc.tf:133` route a single scalar CIDR
value (`var.internal_cidrs[0]` as originally written; `var.internal_cidr` in the
current tree) per AZ.

If internal address space is ever more than one CIDR — which both the plural name
and the HOME_NET list semantics imply — then every CIDR after the first has:

- no route from the firewall subnet back to the TGW, and
- no route from the public/NAT subnet back to the firewall endpoint.

Return traffic is dropped with no error and no log entry. This is the worst
failure mode available in this design, because the forward path succeeds and only
the return path fails.

---

## B2 — Exact fix

Three edits, all in `terraform/modules/nfw_inspection_vpc/`. Edits 2 and 3 also
close out the remaining half of B1.

Design note, since it is the most common misreading of this fix: `internal_cidrs`
entries are **remote destinations reached through the TGW**, so they have no AZ
affinity and are deliberately **not** mapped to specific AZs. Every CIDR is
routed from every AZ. The AZ dimension comes from the per-AZ route tables, not
from the CIDRs. What varies per AZ is the *next hop*, not the destination:
`aws_route.firewall_internal` targets the single TGW (identical in both AZs),
while `aws_route.public_ingress` targets the AZ-local firewall endpoint.

The route tables are intentionally left on `count` here, so the flattened map
must carry both the integer `az_index` (to select the count-indexed route table)
and the `az` name (to select the endpoint from `local.fw_endpoints`, which is
keyed by AZ name at `firewall.tf:4-7`).

### Edit 1 of 3 — `variables.tf` (already applied)

This edit has **already been applied** to the working tree and is recorded here
only for completeness. Replace the `internal_cidrs` block at `variables.tf:44`
with:

```hcl
variable "internal_cidrs" {
  description = "CIDR blocks considered internal. Used for the Suricata HOME_NET rule variable and for return routes from the inspection VPC back to the transit gateway. Every CIDR is routed in every AZ; these are remote destinations reached via the TGW, so they have no AZ affinity."
  type        = list(string)
  default     = ["10.0.0.0/8"]

  validation {
    condition     = length(var.internal_cidrs) > 0
    error_message = "At least one internal CIDR is required."
  }

  validation {
    condition     = alltrue([for c in var.internal_cidrs : can(cidrnetmask(c))])
    error_message = "Each entry in internal_cidrs must be a valid IPv4 CIDR block."
  }

  validation {
    condition     = !contains(var.internal_cidrs, "0.0.0.0/0")
    error_message = "internal_cidrs must not contain 0.0.0.0/0; the default route is managed separately by the egress routes."
  }

  validation {
    condition     = length(distinct(var.internal_cidrs)) == length(var.internal_cidrs)
    error_message = "internal_cidrs must not contain duplicate entries; duplicates produce a duplicate route-key collision when fanning routes out across AZs."
  }
}
```

Rationale for each validation:

| Validation | Rejects | Why it matters |
|---|---|---|
| `length > 0` | empty list | An empty list silently produces zero return routes — B2 in its most complete form. |
| `can(cidrnetmask(c))` | malformed input, IPv6 | `destination_cidr_block` is IPv4-only; `cidrnetmask` fails on both. |
| `!contains("0.0.0.0/0")` | the default route | Collides with the existing `0.0.0.0/0` routes at `inspection_vpc.tf:71` and `:126`, producing an apply-time `RouteAlreadyExists` rather than a plan error. |
| `distinct(...) == ...` | duplicate entries | Duplicates generate a duplicate `"${az}:${cidr}"` key in the `for_each` map below. |

Note: overlap between `internal_cidrs` and `inspection_vpc_cidr` is **harmless**
and intentionally not validated. The default `10.0.0.0/8` fully contains the
default inspection VPC CIDR `10.100.0.0/16`, but a VPC's implicit local route is
both more specific and always preferred, so intra-VPC traffic stays local.

### Edit 2 of 3 — `inspection_vpc.tf`, add the flattened map

Insert this `locals` block at the **top of `inspection_vpc.tf`**, immediately
before the existing `resource "aws_vpc" "inspection" {` at line 1:

```hcl
locals {
  # One entry per (AZ, internal CIDR) pair.
  #
  # internal_cidrs are remote destinations reached through the TGW, so they have
  # no AZ affinity of their own: every CIDR must be routable from every AZ. The
  # AZ dimension here comes from the per-AZ route tables, not from the CIDRs.
  #
  # az_index selects the count-indexed route table
  # (aws_route_table.firewall / aws_route_table.public); az selects the AZ-local
  # firewall endpoint from local.fw_endpoints, which is keyed by AZ name.
  internal_routes = merge([
    for az_index, az in var.availability_zones : {
      for cidr in var.internal_cidrs :
      "${az}:${cidr}" => {
        az_index = az_index
        az       = az
        cidr     = cidr
      }
    }
  ]...)
}
```

Two notes:

- The `merge([...]...)` spread idiom is already used in this repository at
  `terraform/modules/nfw_temp/to_modify.tf:41-51`, so this introduces no new
  pattern.
- `:` is the key separator because it appears in neither AZ names nor IPv4 CIDRs
  (which contain `/`). Do **not** use `-`, since AZ names contain hyphens.

Both `var.availability_zones` and `var.internal_cidrs` are input variables, so
these keys are known at plan time and `for_each` is legal.

The block may alternatively live in `firewall.tf` alongside the existing
`locals` at `firewall.tf:1-19`. It is placed in `inspection_vpc.tf` here because
both consumers are in that file.

### Edit 3 of 3 — `inspection_vpc.tf`, rewrite the two broken routes

**3a.** Replace the whole `aws_route.firewall_internal` block at
`inspection_vpc.tf:75-82`.

Current (broken):

```hcl
resource "aws_route" "firewall_internal" {
  count                  = length(var.availability_zones)
  route_table_id         = aws_route_table.firewall[count.index].id
  destination_cidr_block = var.internal_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.tgw-inspection-vpc-attachment]
}
```

Replacement:

```hcl
resource "aws_route" "firewall_internal" {
  for_each = local.internal_routes

  route_table_id         = aws_route_table.firewall[each.value.az_index].id
  destination_cidr_block = each.value.cidr
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.tgw-inspection-vpc-attachment]
}
```

**3b.** Replace the whole `aws_route.public_ingress` block at
`inspection_vpc.tf:130-137`.

Current (broken):

```hcl
resource "aws_route" "public_ingress" {
  count                  = length(var.availability_zones)
  route_table_id         = aws_route_table.public[count.index].id
  destination_cidr_block = var.internal_cidr
  vpc_endpoint_id        = local.fw_endpoints[var.availability_zones[count.index]]

  depends_on = [aws_networkfirewall_firewall.firewall]
}
```

Replacement:

```hcl
resource "aws_route" "public_ingress" {
  for_each = local.internal_routes

  route_table_id         = aws_route_table.public[each.value.az_index].id
  destination_cidr_block = each.value.cidr
  vpc_endpoint_id        = local.fw_endpoints[each.value.az]

  depends_on = [aws_networkfirewall_firewall.firewall]
}
```

`local.fw_endpoints[each.value.az]` is why the map carries `az` and not only
`az_index`. That value resolves to unknown until apply, exactly as in the current
code, which is fine because it is a resource *value* rather than a `for_each`
*key*.

Leave `aws_route.firewall_egress` (`:68-73`), `aws_route.tgw_egress` (`:99-106`),
`aws_route.public_egress` (`:123-128`), all `aws_route_table` resources, and all
`aws_route_table_association` resources on `count` and otherwise untouched. This
fix changes only the two internal-CIDR routes.

### Resulting route count

| AZs | internal_cidrs | `firewall_internal` | `public_ingress` |
|---|---|---|---|
| 2 | 1 (default) | 2 | 2 |
| 2 | 3 | 6 | 6 |

At the default of one CIDR the fix is behaviourally identical to today. At three
CIDRs it produces 6 routes each instead of 2, closing the blackhole.

### State migration

Resource addresses change from `aws_route.firewall_internal[0]` to
`aws_route.firewall_internal["us-gov-west-1a:10.0.0.0/8"]`, so Terraform plans
destroy-then-create. For a return route on an inspection VPC carrying all
platform traffic, that is a brief but real gap in return traffic for that AZ.

If this stack is already applied anywhere that matters, add `moved` blocks
(requires Terraform >= 1.1; see M5, which recommends `>= 1.3` regardless):

```hcl
moved {
  from = aws_route.firewall_internal[0]
  to   = aws_route.firewall_internal["us-gov-west-1a:10.0.0.0/8"]
}

moved {
  from = aws_route.firewall_internal[1]
  to   = aws_route.firewall_internal["us-gov-west-1b:10.0.0.0/8"]
}

moved {
  from = aws_route.public_ingress[0]
  to   = aws_route.public_ingress["us-gov-west-1a:10.0.0.0/8"]
}

moved {
  from = aws_route.public_ingress[1]
  to   = aws_route.public_ingress["us-gov-west-1b:10.0.0.0/8"]
}
```

`moved` requires literal addresses, so these cannot be generated. Four blocks
total at 2 AZs x 1 CIDR. Delete them once applied.

However: `ci/ci-inspection-vpc-temp.yml` sets `delete_protection: false` and
`log_retention_days: 1`, which suggests this stack is still pre-production. If
nothing real is deployed, skip the `moved` blocks and let the routes recreate —
do not carry migration scaffolding that is not needed.

### Follow-on: if C1 is fixed later

If the route tables are later converted from `count` to `for_each` (see C1):

```hcl
resource "aws_route_table" "firewall" {
  for_each = toset(var.availability_zones)
  vpc_id   = aws_vpc.inspection.id
  tags     = merge(var.tags, { Name = "${var.name_prefix}-firewall-rt-${each.key}" })
}
```

…then `az_index` becomes dead weight. Drop it from `local.internal_routes` and
index with `aws_route_table.firewall[each.value.az].id`. That is the cleaner end
state, but it touches every resource in `inspection_vpc.tf` and is reasonably
sequenced as separate work.

### Verification required for this fix

None of the above has been executed — there is no `terraform` or `tofu` binary in
the review environment. Before merge:

1. `terraform fmt -check` on the module (the `=` alignment above follows
   `terraform fmt` conventions but is unverified).
2. `terraform validate` — confirms B1 is closed and no `internal_cidr` references
   remain: `grep -rn "internal_cidr\b" terraform/modules/nfw_inspection_vpc/`
   should return nothing.
3. `terraform plan` with a multi-CIDR `internal_cidrs` value (for example
   `["10.0.0.0/8", "172.16.0.0/12"]`) to confirm the route count doubles per AZ
   as tabulated above. A single-CIDR plan will **not** exercise the defect and
   will not prove the fix.
4. Confirm `versions.tf` has been raised past `>= 0.15` (M5), since multiple
   `validation` blocks and `optional()` both require newer Terraform.

---

### B3 — The stack never wires HOME_NET at all


`terraform/stacks/firewall-inspection-vpc/variables.tf` declares no
`internal_cidr`/`internal_cidrs` variable, and `stack.tf:16-30` does not pass
one. `ci/ci-inspection-vpc-temp.yml` sets no corresponding `TF_VAR_`.

Consequently, even after B1 is fixed, HOME_NET and both internal return routes
silently fall back to the module default `10.0.0.0/8`.

For a device whose entire function is deciding what traffic is "internal," this
value must be explicit and per-environment, not an inherited module default.

### B4 — Cross-account TGW sharing is missing, and the consumer already depends on it

`transit_gateway.tf:1-10` creates the Transit Gateway inside this module with
`auto_accept_shared_attachments = "disable"`.
`terraform/modules/bosh_vpc/nfw_inspection.tf:27-38` then attaches *spoke* VPCs
to that TGW ID, read from remote state.

There is no `aws_ram_resource_share` anywhere in the repository
(`grep -r aws_ram terraform/ --include=*.tf` returns nothing).

Per `README.md:59-61`, `main` environments live in **separate AWS accounts**. A
TGW attachment from another account requires a RAM resource share, and with
auto-accept disabled it also requires explicit attachment acceptance. If the
inspection VPC and all spokes are same-account, the current code is fine — but
then the documented multi-account story is unbuilt.

Related coupling problem: a Transit Gateway is an account- and region-wide shared
resource, but its lifecycle is now bound to this module. Replacing or destroying
the inspection VPC destroys the TGW that every spoke depends on. Consider
managing the TGW in a separate, longer-lived stack.

This requires an explicit recorded decision either way.

### B5 — `bosh_vpc` now hard-requires the inspection state to exist, unconditionally

`terraform/modules/bosh_vpc/nfw_inspection.tf:5-11` declares:

```hcl
data "terraform_remote_state" "firewall-inspection-vpc" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket
    key    = "firewall-inspection-vpc/terraform.tfstate"
  }
}
```

This has **no `count` or conditional**, while every resource around it is gated
on `var.egress_traffic_through_inspection_vpc` (default `false`). Data sources
are always read. Therefore every `main` and `tooling` stack — **including those
that have opted out of inspection** — now fails to plan unless
`s3://<remote_state_bucket>/firewall-inspection-vpc/terraform.tfstate` exists.

Aggravating factors:

- `var.remote_state_bucket` defaults to `""`
  (`bosh_vpc/variables.tf:91-95`), so the failure surfaces as a confusing bucket
  error rather than a clear one.
- The state key is hardcoded.
- Unlike `terraform/stacks/dns/stack.tf`, the backend config passes no `region`.

This is strictly outside the two paths under review, but it is the consumer of
this module's outputs and part of the same branch, so it is in scope as an
integration defect.

---

## Security and compliance

### S1 — Log retention contradicts the repository's own M-21-31 convention

Every other CloudWatch log group in this repository uses
`retention_in_days = 1096` with an explicit comment citing the 30-month
requirement:

- `terraform/modules/bosh_vpc/vpc.tf:21-22`
- `terraform/modules/network_firewall/main.tf:89`
- `terraform/modules/dns_logging/resolver_logging.tf:5`
- `terraform/modules/elasticsearch_broker/log_group.tf:4`

Here, the stack default is `90` days
(`stacks/firewall-inspection-vpc/variables.tf:84-88`) and CI passes **`1`**
(`ci/ci-inspection-vpc-temp.yml:41`).

Firewall ALERT logs are precisely the security-relevant record that retention
requirements exist to preserve.

Additionally, neither log group sets `kms_key_id` (`firewall.tf:75-87`). That is
consistent with the rest of the repository, but is worth fixing here rather than
propagating.

> Controls: AU-11 (Audit Record Retention), AU-9 (Protection of Audit
> Information), SC-28 (Protection of Information at Rest)

### S2 — The inspection VPC has no VPC flow logs

`terraform/modules/bosh_vpc/vpc.tf:70-75` creates an `aws_flow_log` with
`traffic_type = "ALL"` for the main VPC. The inspection VPC — which will carry
*all* north-south and east-west traffic for the platform — has none.

Network Firewall FLOW logs are not a substitute. They do not cover traffic that
bypasses the firewall endpoints (for example, a misrouted subnet), which is
exactly the condition VPC flow logs are needed to detect.

> Controls: AU-2 (Audit Events), AU-12 (Audit Generation), SI-4 (System
> Monitoring)

### S3 — The firewall cannot drop anything, and there is no single switch to change that

`firewall.tf:12-18`:

```hcl
count_only = var.firewall_rule_groups_count_only || rg.override_action_to_count
```

- `override_action_to_count` defaults to `true`
  (module `variables.tf:57`), and the stack sets it `true` explicitly
  (`stacks/.../variables.tf:62`).
- `firewall_rule_groups_count_only` defaults to `true`
  (`stacks/.../variables.tf:69`).

Because the combinator is `||`, flipping the global switch to `false` still
leaves every rule group in alert-only mode. Achieving enforcement requires
editing per-group configuration *and* the global flag.

Alert-only is a defensible initial rollout posture. Shipping a global "enforce"
switch that does not enforce is not. Either make the per-group field default to
`false` and let the global flag act as the override, or remove the global flag.

> Controls: SC-7 (Boundary Protection), CM-6 (Configuration Settings)

### S4 — `stateful_default_actions` is not set

`firewall.tf:24-30` sets `stateless_default_actions`,
`stateless_fragment_default_actions`, and
`stateful_engine_options { rule_order = "STRICT_ORDER" }`, but never
`stateful_default_actions`.

Under strict rule order the available values are `aws:drop_strict`,
`aws:drop_established`, `aws:alert_strict`, and `aws:alert_established`. Leaving
this unset means the effective posture for unmatched stateful traffic is decided
by the service-side default rather than by this code.

For a boundary-protection device, pin it explicitly. The specific service
default is deliberately not asserted here — that ambiguity is the finding.

> Controls: SC-7 (Boundary Protection), CM-6 (Configuration Settings)

### S5 — Only one of three change-protection knobs is wired

`firewall.tf:59-73` sets `delete_protection` but not
`subnet_change_protection` or `firewall_policy_change_protection`. Both default
to disabled, so the policy and subnet mappings of the platform's inspection
device can be changed without a guardrail.

Note also that `ci/ci-inspection-vpc-temp.yml:39` sets
`TF_VAR_delete_protection: false`.

> Controls: CM-5 (Access Restrictions for Change), CM-3 (Configuration Change
> Control)

### S6 — One managed rule group, no stateless rules, no egress domain allow-list

The only configured group is `AttackInfrastructureStrictOrder`
(`stacks/.../variables.tf:59-63`).

By comparison:

- `terraform/modules/network-firewall-inspection-vpc/firewall.tf:62` (untracked
  scratch module) defines an `egress_allow_list` stateful rule group.
- `terraform/modules/network_firewall/main.tf:62` sets
  `enabled_analysis_types = ["TLS_SNI", "HTTP_HOST"]`.

Neither made it into this module. Whether that is intentional scope-cutting or an
omission needs to be stated in the module README.

### S7 — Default security group and NACLs are unmanaged in the inspection VPC

`terraform/modules/bosh_vpc/vpc.tf:81-105` manages NACL deny rules for the main
VPC. Nothing in this module touches the inspection VPC's default security group
(permissive intra-VPC by default) or its NACLs.

Practical impact today is low, since the inspection VPC hosts no instances, but
an unrestricted default security group is a standard scan finding.

> Controls: SC-7 (Boundary Protection), CM-7 (Least Functionality)

### S8 — Personal name in infrastructure tags

`ci/ci-inspection-vpc-temp.yml:23-27` sets `owner = "Steve"` and
`status = "development"` as default tags on what becomes shared platform
infrastructure. Use a team or system identifier instead.

---

## Correctness and reliability

### C1 — `count`-indexed subnets over parallel lists make reordering destructive

`inspection_vpc.tf` indexes `availability_zones`, `firewall_subnet_cidrs`,
`tgw_subnet_cidrs`, and `public_subnet_cidrs` by `count.index` throughout
(lines 9-32, 41-56, 60-143).

Reordering or inserting into any of these lists shifts every index, forcing
replacement of subnets, NAT gateways, EIPs, and the TGW attachment. `for_each`
keyed by AZ name would make this safe and would also make resource addresses
readable in plan output.

### C2 — `prevent_destroy` on a counted EIP will hard-fail teardown and any AZ change

`inspection_vpc.tf:41-48` adds `lifecycle { prevent_destroy = true }` to
`aws_eip.ngw` (uncommitted change).

Combined with C1, any reorder of the AZ list becomes an unrecoverable apply error
that requires a code edit to resolve. It also blocks `terraform destroy`
outright.

`terraform/modules/bosh_vpc/network_private.tf:76-90` sets the same flag, so this
follows existing precedent — but that precedent applies to a resource that is not
indexed off a reorderable list.

Note also that there is no destroy job for this stack in CI, unlike other stacks
(`bootstrap_and_teardown.md:89-91`).

### C3 — No length or containment validation on the three CIDR lists

`variables.tf:23-27` validates `length(var.availability_zones) == 2`, but nothing
validates that `firewall_subnet_cidrs`, `tgw_subnet_cidrs`, and
`public_subnet_cidrs` have matching length, fall inside `inspection_vpc_cidr`, or
do not overlap one another.

A short list produces an index-out-of-range error at plan time. Either add cheap
`validation` blocks, or derive the subnets with `cidrsubnet()` and eliminate three
variables entirely.

### C4 — The two-AZ validation is enforced nowhere it matters

Every resource uses generic `length(var.availability_zones)`. Nothing in the
module actually requires exactly two AZs.

Either remove the validation or document the real constraint. As written it is an
arbitrary limit with a misleading error message ("This module is designed for
exactly two AZs").

### C5 — No uniqueness validation on rule group priorities

`STRICT_ORDER` requires unique priorities across stateful rule group references.
Duplicates in `firewall_managed_rule_groups` fail at apply time rather than plan
time. This is a one-line `validation` block.

### C6 — `firewall_managed_rule_groups` defaults to `[]` in the module

`variables.tf:59`. A caller who omits this input gets a successfully created
firewall policy with zero stateful rule groups and no warning.

For a security module, this should be a required input with no default.

### C7 — The variable claims to support custom rule groups, but the code cannot

`variables.tf:53` describes the input as "managed (or custom) stateful rule
groups," but `firewall.tf:37` hardcodes `:aws-managed:stateful-rulegroup/` into
the constructed ARN. Custom rule groups are impossible.

Additionally, `override { action = "DROP_TO_ALERT" }` (`firewall.tf:39-44`) is
only valid against managed rule groups.

Either correct the description or accept full ARNs as input.

### C8 — `override_action_to_count` is misnamed

The action actually applied is `DROP_TO_ALERT` (`firewall.tf:42`), not count. The
variable description says "count/alert-only mode." Alert and count are different
behaviours — alert generates log records, count does not. Settle on one
vocabulary.

### C9 — No cross-AZ failover

`firewall.tf:68` routes each firewall subnet's default route to *that AZ's* NAT
gateway, and `inspection_vpc.tf:130-137` routes each public subnet's internal
route to *that AZ's* firewall endpoint.

If one AZ's NAT gateway or firewall endpoint fails, that AZ's traffic drops with
no fallback path.

This is the standard trade-off for preserving flow symmetry, and
`appliance_mode_support = "enable"` (`transit_gateway.tf:17`) is correctly set,
which is what makes symmetry work. But this availability characteristic should be
documented rather than discovered during an incident.

### C10 — `/28` subnets sit at the AWS floor with zero headroom

`/28` is the documented minimum for Network Firewall subnets, leaving 11 usable
addresses after AWS reserves 5. That is acceptable for the firewall and TGW
subnets. For the public/NAT subnets it leaves no room to add anything later.

### C11 — `bosh_vpc` TGW subnets have no route table association

`terraform/modules/bosh_vpc/nfw_inspection.tf:14-24` creates the TGW attachment
subnets but no `aws_route_table_association`, so they fall through to the VPC main
route table.

This is likely intentional, but implicit reliance on the main route table
warrants an explicit comment or an explicit association.

### C12 — `bosh_vpc.tgw_cidr_blocks` default is unsafe per environment

An uncommitted change moves the default from
`["10.100.1.0/28", "10.100.1.16/28"]` to `["10.0.3.0/28", "10.0.3.16/28"]`
(`bosh_vpc/variables.tf:86-89`).

The new value sits inside the *default* `vpc_cidr` of `10.0.0.0/16`. However,
real environments pass `((development_vpc_cidr))`, `((staging_vpc_cidr))`, and
`((production_vpc_cidr))` from the pipeline (`ci/pipeline.yml:762, 1050, 1303`),
while `tgw_cidr_blocks` is **not** parameterized per environment.

Any environment whose VPC CIDR is not `10.0.0.0/16` gets an invalid subnet. Any
environment already using `10.0.3.x` for RDS or services gets a collision.

This must become a required per-environment input.

### C13 — Dead variable in `bosh_vpc`

`bosh_vpc/variables.tf:80-84` declares `transit_gateway_id`. It is plumbed from
nowhere and used nowhere — the code reads the TGW ID from remote state instead.
Remove it.

---

## Maintainability and process

### M1 — Three overlapping firewall modules, two of them untracked scratch

- `terraform/modules/network-firewall-inspection-vpc/` — 14 files, **untracked**,
  duplicates this work.
- `terraform/modules/nfw_temp/` — **untracked**;
  `module_usage.tf:2` sources `./modules/network-firewall-centralized`, which
  does not exist.
- `terraform/modules/network_firewall/` — **tracked**, and referenced by nothing
  (`grep -r "modules/network_firewall" terraform/ --include=*.tf` returns no
  hits).

`validate.sh:9` only walks `terraform/stacks`, so broken modules are never
validated by CI.

Delete the scratch directories before merge, and make an explicit call on
`network_firewall`.

### M2 — Commented-out dead code throughout

- `firewall.tf:10` — `all_spoke_cidrs` local
- `firewall.tf:36` — `deep_threat_inspection`
- `transit_gateway.tf:3` — `amazon_side_asn`
- `outputs.tf:21-24, 31-34` — two commented spoke outputs

Delete it; git preserves the history.

### M3 — Duplicate outputs

`outputs.tf:26-29` (`tgw_route_table_inspection_id`) and `outputs.tf:46-49`
(`ec2_transit_gateway_route_table_id`) return the identical value
(`aws_ec2_transit_gateway_route_table.tgw.id`). Both are re-exported by the stack
(`stacks/.../outputs.tf:11, 16`).

`bosh_vpc` consumes only the second (`nfw_inspection.tf:61`). Drop the first.

### M4 — Stack has no `versions.tf`

`main`, `tooling`, `dns`, `ecr`, and `external` all have one;
`firewall-inspection-vpc` does not.

Related: the `provider "aws"` block (`stack.tf:6-14`) sets no `region`, unlike
`stacks/main/stack.tf:35-36`. It works because CI sets `AWS_DEFAULT_REGION`, but
the dependency is implicit.

### M5 — `required_version = ">= 0.15"` is factually wrong for this module

`versions.tf:2`. The module uses `optional()` with a default value in
`firewall_managed_rule_groups` (`variables.tf:57`), which requires **Terraform
>= 1.3**. It also uses variable `validation` blocks.

Under 0.15 this module cannot parse. This is copied boilerplate from the other
modules; it needs to be `>= 1.3`.

### M6 — Provider versions are unpinned in practice

`.gitignore:16` excludes `.terraform.lock.hcl` repository-wide, and the two local
lock files already disagree — module resolved `6.57.1`, stack resolved `6.58.0`.
With only `< 7.0.0` as a constraint, CI resolves to whatever is latest at run
time.

This is a pre-existing repository-wide decision rather than a defect introduced
here. But given that this stack is a boundary-protection device, committing its
lock file is worth reconsidering.

> Controls: CM-2 (Baseline Configuration), SR-3 (Supply Chain Controls)

### M7 — The CI file is not mergeable as written

`ci/ci-inspection-vpc-temp.yml`:

- Named `-temp`.
- Pins the git resource to `branch: firewall-inspection-vpc` (line 69).
- Has both `trigger: true` lines commented out (lines 10, 48).
- Sets `TF_VAR_delete_protection: false` (line 39) and
  `TF_VAR_log_retention_days: 1` (line 41).
- Lives outside `ci/pipeline.yml`, so it inherits none of the `notify-slack`,
  `set-self`, or `passed:` conventions used by every other job.

This needs to become real jobs in `ci/pipeline.yml` before merge.

### M8 — Documentation is two sentences

`terraform/modules/nfw_inspection_vpc/README.md` is 157 bytes. Nothing documents:

- the routing design (three route table tiers, and why `appliance_mode_support`
  matters),
- the TGW propagation contract with `bosh_vpc`,
- the required inputs,
- the alert-only rollout plan and its exit criteria,
- the fact that spoke wiring lives in `bosh_vpc` behind
  `egress_traffic_through_inspection_vpc`.

The scratch module this replaces has a 4.4 KB README. For infrastructure that
mediates all platform traffic, this is the finding most likely to cost someone a
bad night.

> Controls: SA-5 (System Documentation)

### M9 — Naming inconsistency

`aws_ec2_transit_gateway_vpc_attachment.tgw-inspection-vpc-attachment`
(`transit_gateway.tf:13`) uses hyphens; everything else in the module is
snake_case. The name is also redundant given its resource type.

### M10 — Process observation: evidence of local applies

`terraform/stacks/firewall-inspection-vpc/` contains a 482-byte
`terraform.tfstate` and an 87 KB `terraform.tfstate.backup` in the working
directory.

Both are gitignored and **not** committed — confirmed via `git ls-files`, which
lists only `outputs.tf`, `stack.tf`, and `variables.tf` as tracked. There is no
disclosure in the repository.

However, their presence indicates local `apply`/`destroy` runs against this
stack, which `README.md:110-114` explicitly prohibits ("we never apply this
configuration manually"). Worth confirming that no shared state was modified
outside CI.

> Controls: CM-3 (Configuration Change Control), CM-5 (Access Restrictions for
> Change)

---

## What is done well

Recorded so the findings above are not read as a wholesale rejection:

- `appliance_mode_support = "enable"` on the inspection attachment
  (`transit_gateway.tf:17`) — required for flow symmetry through a stateful
  appliance, and easy to miss.
- `default_route_table_association` and `default_route_table_propagation` both
  disabled on the TGW, with explicit route tables (`transit_gateway.tf:5-6`) —
  the correct pattern.
- `use_fips_endpoint = true` (`stack.tf:7`) and partition-aware ARN construction
  via `data.aws_partition` (`firewall.tf:37`), which correctly handles
  `aws-us-gov` instead of hardcoding it the way
  `modules/network_firewall/main.tf:52` does.
- `map_public_ip_on_launch = false` on the public subnets
  (`inspection_vpc.tf:30`).
- Deriving `fw_endpoints` from `firewall_status[0].sync_states` keyed by AZ
  (`firewall.tf:4-7`) is the correct way to target firewall endpoints per AZ.
- The `nat_gateway_eips` output fix from `aws_eip.ngw` to
  `aws_eip.ngw[*].public_ip` (`outputs.tf:43`) — the prior version exported
  entire EIP objects.
- The three-tier route table separation (firewall / TGW / public) is
  architecturally correct.

---

## Suggested merge gate

**Must fix before merge:** B1, B2, B3, B5, S1, S3, M1, M5, M7

**Must have a recorded decision before production traffic:** B4 (RAM sharing and
multi-account topology), S4 (stateful default action), C12 (`tgw_cidr_blocks`
per environment)

**Should fix in this PR:** S2, S5, C1, C2, C3, C6, C7, M2, M3, M4, M8

**Follow-up / backlog:** S6, S7, S8, C4, C5, C8, C9, C10, C11, C13, M6, M9, M10

### Architecture Decision Records

Per AGENTS.md §15.1, the following meet the ADR trigger threshold and should be
recorded before the enforcement flip rather than after:

- **B4** — TGW topology, lifecycle ownership, and cross-account RAM sharing
  (deployment architecture change)
- **S3 / S4** — firewall enforcement posture and default actions
  (authorization/boundary-protection policy change)

### Verification required

This review could not run `terraform validate`, `terraform plan`, or
`terraform fmt -check`. Before merge, the repository's own PR checks
(`ci/pipeline.yml:101-146` → `ci/scripts/terraform_fmt.sh` and `validate.sh`)
must pass, and B1 must be confirmed resolved by a successful plan.

Note that `validate.sh:9` only walks `terraform/stacks`, so it will not catch
defects in modules that no stack references — relevant to M1.
