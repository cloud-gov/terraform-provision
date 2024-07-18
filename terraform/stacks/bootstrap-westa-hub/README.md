# New Hub

This stack is used before the bootstrap stack for new hubs to:

 - Create the terraform-provision iam user.  This will generate aws access key and secret needed to create a cg-provision.yml (aka credentials) file
 - The s3 backend for all of the rest of the terraform runs in this hub


## Verify first attempt


Comment out the backend definition in `stacks/bootstrap-hub/bootstrap.tf` so the file is created locally :

```
#terraform {
#  backend "s3" {
#  }
#}
```

To run this stack, from a laptop with `aws-vault` access configured, clone the repo and switch to the new stack:

```
git clone https://github.com/cloud-gov/cg-provision
cd cg-provision/terraform/stacks/bootstrap-westa-hub
```



Now run the init, plan, and apply:

```
aws-vault exec gov-pipeline-admin -- bash

export STACK_NAME=bootstrap-westa-hub
export S3_TFSTATE_BUCKET=westa-hub-terraform-state
export TF_VAR_tfstate_bucket_name=westa-hub-terraform-state

init_args=(
  "-backend=true"
  "-backend-config=path=terraform.tfstate"
)

terraform init "${init_args[@]}" -upgrade

terraform apply
```


This will output values for the `aws_s3_tfstate_bucket`, `aws_access_key_id` and `aws_secret_access_key` for `credentials.yml` aka `cg-provision.yml`:

```
aws_s3_tfstate_bucket = "westa-hub-terraform-state"
terraform_provision_access_id = "XXXXXXXXXXXXXXXXXXXX"
terraform_provision_access_secret = <sensitive>
```

To get the value of the access secret, run:

```
terraform output -json terraform_provision_access_secret
```

Copy up the tfstate file to the newly created bucket since it only local:

```
aws s3 cp terraform.tfstate "s3://${S3_TFSTATE_BUCKET}/${STACK_NAME}/terraform.tfstate" --sse AES256
```


## Now try and migrate this deployment over to the new bucket

Add this back to stacks/bootstrap-hub/bootstrap.tf :

```
terraform {
  backend "s3" {
  }
}
```

Back on the command line, rerun:

```

export STACK_NAME=bootstrap-westa-hub
export S3_TFSTATE_BUCKET=westa-hub-terraform-state
export TF_VAR_tfstate_bucket_name=westa-hub-terraform-state

init_args=(
  "-backend=true"
  "-backend-config=encrypt=true"
  "-backend-config=bucket=${S3_TFSTATE_BUCKET}"
  "-backend-config=key=${STACK_NAME}/terraform.tfstate"
)

terraform init "${init_args[@]}" -upgrade

terraform apply
```

You should see this as output:

```
No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
```

Now you can remove the local copy of the terraform tfstate files:

```
rm terraform.tfstate
rm terraform.tfstate.backup
```

The repo is now safe to commit.

## Running the second and subsequent times

The terraform state file is now in the bucket this stack creates, to make changes which don't involve DELETING the bucket, run:

```
aws-vault exec gov-pipeline-admin -- bash

export STACK_NAME=bootstrap-hub
export S3_TFSTATE_BUCKET=terraform-state-hub
export TF_VAR_tfstate_bucket_name=westa-hub-terraform-state

init_args=(
  "-backend=true"
  "-backend-config=encrypt=true"
  "-backend-config=bucket=${S3_TFSTATE_BUCKET}"
  "-backend-config=key=${STACK_NAME}/terraform.tfstate"
)

terraform init "${init_args[@]}" -upgrade

terraform apply

```