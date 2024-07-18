# Cloud.gov Provisioning System

This repository holds the terraform configuration (and BOSH vars and ops-files)
to bootstrap our infrastructure.

Be sure to read the internal developer documentation ("cg-provision") for
non-public information about using this repository.

## Local development

### Git hooks

This project uses [`pre-commit`](https://pre-commit.com/) to manage git hooks. To make sure your code is formatted and checked automatically, [install pre-commit](https://pre-commit.com/index.html#installation) then run `pre-commit install` on this repo.

_n.b., pre-commit recommends `pip install pre-commit`to install, which will install it on your system python.
You probably don't want this, and should instead `pipx install pre-commit`, which will automagically install it into its own virtual environment._

## Layout

### Terraform

Our Terraform code is organized by two concepts, with two corresponding directories.

* **Modules** are reusable units of terraform code. Each module describes a useful concept in our infrastructure. A module can be reused in different contexts by declaring variables that the caller must pass in. Modules are located in `terraform/modules`.
  * Two important modules are `modules/stack/base` and `modules/stack/spoke`.
  * Read more about Terraform modules: https://developer.hashicorp.com/terraform/language/modules
* **Stacks** combine and configure modules for use in an environment. They are also parameterized by variables, with values such as the environment name. Stacks are located in `terraform/stacks`.

As an example, if we wanted to write terraform code to deploy several CloudFront distributions in front of three load balancers in an environment, we could:

1. Create a `cloudfront` module that declares a CloudFront distribution, a Shield Advanced resource to protect it, and an Access Control List (ACL) association between the distribution and an ACL. (The ACL itself is not declared in the module.) It could take an origin, a list of domains, and an ACL ARN as variables.
2. Create a `cloudfront` stack uses the `cloudfront` module three times, once for each load balancer in the environment. It would pass an external domain and load balancer domain to each module. It could also declare a single ACL for the environment and pass its ARN to each `cloudfront` module. The stack could take an environment name as a variable.
3. Add a job to Concourse for each environment. Each job would deploy the `cloudfront` stack and pass the environment name as a variable.

In the future, we would like to add a third concept: An entire **runtime environment**. An environment would combine multiple stacks to represent the entire cloud.gov runtime stack. This collection of resources could be deployed as a single unit to a new AWS region or multiple times in the same region.

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

## How Concourse Creates AWS Resources

The Concourse worker VMs must have AWS access to create and apply Terraform plans. How they are given that access depends on the partition being changed.

You can determine how a failing Concourse container is configured by hijacking it. Connect to the container (see `fly hijack --help`) and run `aws configure list` to see the current configuration.

### GovCloud

The Concourse worker VMs are associated with an IAM role with read-write access to GovCloud resources. The AWS SDK in the Concourse containers is automatically configured to fetch credentials from the [Instance metadata service](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html). No further configuration is necessary - note that no access keys are passed to GovCloud jobs in [pipeline.yml](./ci/pipeline.yml).

AWS IAM roles documentation: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html

### Commercial Stacks

Each Concourse job that manages AWS Commercial resources must override the Concourse worker's IAM role. The jobs set the `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `AWS_DEFAULT_REGION` environment variables to do this. Environment variables [have higher precedence](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html#cli-configure-quickstart-precedence) in the AWS SDK, so they are used instead of the IAM role. No further configuration in Terraform is necessary.

### DNS and CloudFront Stacks

The DNS stack is a special case because it must read state from GovCloud but read and write resources and state to Commercial. AWS IAM users [cannot have cross-partition permissions](https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_cross-account-with-roles.html), so the job must use two separate AWS accounts (one for each partition).

To achieve this, the Concourse jobs pass an access key to a Commercial IAM user as a TF_VAR instead of using the standard `AWS_*` environment variables. (Setting `AWS_` variables would make the AWS SDK use them by default, and we want it to continue using the GovCloud IAM role by default.)

The IAM role and `TF_VAR_` credentials are used as follows:

* The `terraform init` command is run with the Commercial credentials using [this script](https://github.com/cloud-gov/cg-pipeline-tasks/blob/ca4120f9ca5c56cb16b8550de16d5b097190e466/terraform-apply.sh#L40-L48). This configures the s3 backend for the DNS stack to be set up in the Commercial account.
* The terraform provider is configured with the Commercial credentials, ensuring that all resources will be created in the Commercial account.
* The `terraform_remote_state` data blocks for each GovCloud s3 state object are configured with the GovCloud region. Because they are accessed using Terraform's initialization process, but separately from the initial `terraform init`, they are not passed the Commercial credentials. Without any credentials set explicitly, the AWS SDK uses the GovCloud IAM role.

## Deployment Workflow

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
