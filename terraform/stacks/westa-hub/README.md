##Create new tooling environment

This stack is run after `bootstrap` and `bootstrap-hub` are created so that there is an s3 bucket to store the state file for this terraform run.

## First deployment

This is done manually leveraging `aws-vault`:

```
git clone https://github.com/cloud-gov/cg-provision
cd cg-provision/terraform/stacks/hub
```


Now run the init, plan, and apply:

```
aws-vault exec gov-pipeline-admin -- bash

STACK_NAME=hub
S3_TFSTATE_BUCKET=terraform-state-hub
TF_VAR_terraform_state_bucket="terraform-state-hub"
TF_VAR_aws_default_region="us-gov-west-1"


... redacted

```