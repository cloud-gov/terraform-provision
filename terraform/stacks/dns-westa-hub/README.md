# Create new tooling environment

This stack is run after `bootstrap`, `bootstrap-westa-hub` and `westa-hub` are created via terraform runs.

After running the stack `westa-hub` so that the load balancers are created, run this stack to generate the DNS entries needed for Route53 on the commercial side.

It is important to run the terraform against the new tooling account and NOT the commercial account even though it will connect to the commercial account to create the resources in `stacks.tf` (observe the provider configuration for aws).


Note: the resulting terraform state file from the `terraform apply...` below will be saved to the new tooling state bucket and NOT the commercial account.


Sample tfvars file contents:

```
aws_access_key: AKIAXXXXXXXXXXXXXXX
aws_region: us-east-1
aws_secret_key: 5XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXq
cloudfront_zone_id: ZXXXXXXXXXXXXX
remote_state_bucket: westa-hub-terraform-state
remote_state_region: us-gov-west-1
tooling_stack_name: westa-hub
```


Create a tfvars file and upload it to the terraform state s3 bucket:

```
aws-vault exec gov-pipeline-admin -- bash

## THIS NEEDS TO BE RUN FROM NEW WESTA-HUB ACCOUNT, NOT COMMERCIAL
export STACK_NAME=dns-westa-hub                        # different than westa-hub, note the dns bit
export S3_TFSTATE_BUCKET=westa-hub-terraform-state     # Use the existing bucket created by stack boostrap-westa-hub

vim "${STACK_NAME}.tfvars"                             # And create the file (TODO: create example file)
aws s3 cp "${STACK_NAME}.tfvars" "s3://${S3_TFSTATE_BUCKET}/${STACK_NAME}/${STACK_NAME}.tfvars" --sse AES256
```


Now we can move on to deploying this stack manually leveraging `aws-vault`:

```
git clone https://github.com/cloud-gov/cg-provision
cd cg-provision/terraform/stacks/dns-westa-hub
```


Now run the init, pull down the tfvars file and apply:

```
aws-vault exec gov-pipeline-admin -- bash

## THIS NEEDS TO BE RUN FROM NEW WESTA-HUB ACCOUNT, NOT COMMERCIAL
export STACK_NAME=dns-westa-hub                        # different than westa-hub, note the dns bit
export S3_TFSTATE_BUCKET=westa-hub-terraform-state     # Use the existing bucket created by stack boostrap-westa-hub

# Note: the rest of the variables are in the dns-westa-hub.tfvars file, grab a copy from the s3 bucket
aws s3 cp "s3://${S3_TFSTATE_BUCKET}/${STACK_NAME}/${STACK_NAME}.tfvars" "${STACK_NAME}.tfvars" --sse AES256

init_args=(
  "-backend=true"
  "-backend-config=encrypt=true"
  "-backend-config=bucket=${S3_TFSTATE_BUCKET}"
  "-backend-config=key=${STACK_NAME}/terraform.tfstate"
)

terraform init "${init_args[@]}" -upgrade

terraform apply -var-file="${STACK_NAME}.tfvars"
```