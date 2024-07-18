# Create new tooling environment

This stack is run after `bootstrap-westa-hub` is created so that there is an s3 bucket to store the state file for this terraform run.

## First deployment

This is done manually leveraging `aws-vault`:

```
git clone https://github.com/cloud-gov/cg-provision
cd cg-provision/terraform/stacks/bootstrap
```


Now run the init, plan, and apply:

```
aws-vault exec gov-pipeline-admin -- bash

export STACK_NAME=bootstrap
export S3_TFSTATE_BUCKET=westa-hub-terraform-state
export TF_VAR_use_vpc_peering="0"
export TF_VAR_tooling_state_bucket="westa-hub-terraform-state"
export TF_VAR_tooling_stack_name="westa-hub"



init_args=(
  "-backend=true"
  "-backend-config=encrypt=true"
  "-backend-config=bucket=${S3_TFSTATE_BUCKET}"
  "-backend-config=key=${STACK_NAME}/terraform.tfstate"
)

terraform init "${init_args[@]}" -upgrade

terraform apply
```

## Where to next?

Now deploy the `westa-hub` stack.  When that is complete, come back here to set `use_vpc_peering` to "1" and run:

```
aws-vault exec gov-pipeline-admin -- bash

export STACK_NAME=bootstrap
export S3_TFSTATE_BUCKET=westa-hub-terraform-state
export TF_VAR_use_vpc_peering="1"
export TF_VAR_tooling_state_bucket="westa-hub-terraform-state"
export TF_VAR_tooling_stack_name="westa-hub"



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
