# Cloud.gov Provisioning System

This repository holds the terraform configuration (and BOSH vars and ops-files)
to bootstrap our infrastructure.

Be sure to read the internal developer documentation ("cg-provision") for
non-public information about using this repository.

## Layout

### Terraform

The main terraform directories are:

* `modules`: where we decompose our configuration into [Terraform
  modules](https://www.terraform.io/docs/configuration-0-11/modules.html)
* `modules/stack/base` & `modules/stack/spoke`: the main modules that define
  the bulk of each environment
* `stacks`: the various "environments"

#### Environments

The `main` stack is a template that is used to provision the production,
staging, and development "environments."

The `regionalmasterbosh` stack contains our masterbosh for a given region, which deploys the tooling BOSH for that region.
The tooling BOSH then deploys the BOSH directors in the main stacks across all accounts in that region.

The `tooling` stack is the same as the `regionalmasterbosh` stack, but has some extras from before we started going multi-region
and multi-account:
  - concourse and staging concourse
  - buckets that we need only one of across all accounts and regions
  - some things that really should be in child environment accounts 
  - nessus
In the future, we should work towards disentagling these pieces out, so the old tooling is deployed as a regionalmasterbosh and the 
_other_ stuff is its own stack(s)

The `external` and `dns` stacks are both outside of GovCloud (commercial AWS).

I believe the `test` stack is unused, and there's [a story to remove
it](https://github.com/18F/cg-product/issues/1277).

#### Wiring up users

As mentioned above, we have four categories of environment:
- `main` - this is the thing we're actually after. It's the pieces that directly
  support the platform components. There should be several of these across multiple 
  AWS accounts
- `tooling` - this is used to support the things in the `main` platform - our CI
  system, managment tools such as Nessus, etc.
- `external` - this manages some things that don't (or historically didn't) exist
  in govcloud (really just cloudfront and the users, etc, to support it). There's 
  one of these per `main` environment
- `dns` - this manages route53. There's exactly one of these, although we really
  should split it out to one per `main` + one for `tooling`

To allow the `tooling` environment to manage the `main` environment, there's a
`tooling-terraform` role associated with each `main` environment, which has an 
assumerole policy allowing access by concourse workers in the `tooling` account.

To add a new `main` environment, see the [README here](./scripts/add_environment/README.md)

### BOSH

The `bosh` directory contains vars and opsfiles for use by the BOSH directors.

## Development Workflow

Since IaaS is a shared resource (we don't have the money or time to provision
entire stacks for each developer), we never apply this configuration manually.
Instead, all execution is done through the Concourse pipeline, which is
configured to first run `terraform plan`, and then wait for manual triggering
before running `terraform apply`.

If you want to make infrastructure changes:

1. Create a branch and pull-request with your changes and ask for review and
   merge from a teammate.
1. Once the teammate :thumbsup: the changes, head over to the Concourse
   pipeline and review the resultant Terraform plan output.
1. If the plan looks like what you intended, then manually trigger the
   appropriate apply jobs.

## Other Points of Note

You may see `access_key_id_prev` and `aws_key_id_prev` as outputs for our `iam`
modules. [These are used for cred
rotation](https://cloud.gov/docs/ops/runbook/rotating-iam-users/#rotating-iam-user-access-key-ids-and-secret-access-keys)

`modules/stack/spoke` composes `modules/stack/base` and some of the VPC
modules.  It's not entirely clear why, and why the VPC modules weren't simply
included in `base` (removing `spoke` altogether).
