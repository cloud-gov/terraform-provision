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

The `tooling` stack contains our "proto-BOSH", which deploys the tooling BOSH.
The tooling BOSH then deploys the BOSH directors in the main stacks.

The `external` and `dns` stacks are both outside of GovCloud (commercial AWS).

I believe the `test` stack is unused, and there's [a story to remove
it](https://github.com/18F/cg-product/issues/1277).

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
