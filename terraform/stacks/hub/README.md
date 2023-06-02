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

TF_VAR_aws_default_region="us-gov-west-1"
TF_VAR_billing_bucket="cg-billing-hub-*"
TF_VAR_bosh_release_bucket="hub-cloud-gov-bosh-releases"
TF_VAR_bucket_prefix="hub"
TF_VAR_build_artifacts_bucket="hub-cg-build-artifacts"
TF_VAR_buildpack_notify_bucket="hub-buildpack-notify-state-*"
TF_VAR_cg_binaries_bucket="hub-cg-binaries"
TF_VAR_cloudtrail_bucket="hub-cg-s3-cloudtrail"
TF_VAR_container_scanning_bucket_name="hub-cg-container-scanning"
TF_VAR_log_bucket_name="hub-cg-elb-logs"
TF_VAR_pgp_keys_bucket_name="hub-cg-pgp-keys"
TF_VAR_semver_bucket="cg-semver-hub"
TF_VAR_stack_description="hub"
TF_VAR_terraform_state_bucket="terraform-state-hub"
TF_VAR_varz_bucket="cloud-gov-varz-hub"
TF_VAR_varz_bucket_stage="cloud-gov-varz-stage-hub"

TF_VAR_blobstore_bucket_name="hub-bosh-tooling-blobstore"





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