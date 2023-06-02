# Create new tooling environment

This stack is run after `bootstrap-hub` is created so that there is an s3 bucket to store the state file for this terraform run.

## First deployment

This is done manually leveraging `aws-vault`:

```
git clone https://github.com/cloud-gov/cg-provision
cd cg-provision/terraform/stacks/bootstrap
```


Now run the init, plan, and apply:

```
aws-vault exec gov-pipeline-admin -- bash

STACK_NAME=bootstrap
S3_TFSTATE_BUCKET=terraform-state-hub
TF_VAR_use_vpc_peering="0"
TF_VAR_tooling_state_bucket="terraform-state-hub"
TF_VAR_tooling_stack_name="hub"
TF_VAR_varz_bucket="cloud-gov-varz-hub" 
TF_VAR_varz_bucket_stage="cloud-gov-varz-stage-hub"
TF_VAR_semver_bucket_name="cg-semver-hub"



init_args=(
  "-backend=true"
  "-backend-config=encrypt=true"
  "-backend-config=bucket=${S3_TFSTATE_BUCKET}"
  "-backend-config=key=${STACK_NAME}/terraform.tfstate"
)

terraform init "${init_args[@]}" -upgrade

terraform plan

terraform apply
```

## Where to next?

Now deploy the `tooling` stack.  When that is complete, come back here to set `use_vpc_peering` to "1" and run:

```
aws-vault exec gov-pipeline-admin -- bash

STACK_NAME=bootstrap
S3_TFSTATE_BUCKET=terraform-state-hub
TF_VAR_use_vpc_peering="1"
TF_VAR_tooling_state_bucket="terraform-state-hub"
TF_VAR_tooling_stack_name="hub"
TF_VAR_varz_bucket="cloud-gov-varz-hub" 
TF_VAR_varz_bucket_stage="cloud-gov-varz-stage-hub"
TF_VAR_semver_bucket_name="cg-semver-hub"

init_args=(
  "-backend=true"
  "-backend-config=encrypt=true"
  "-backend-config=bucket=${S3_TFSTATE_BUCKET}"
  "-backend-config=key=${STACK_NAME}/terraform.tfstate"
)

terraform init "${init_args[@]}" -upgrade

terraform plan

terraform apply
```