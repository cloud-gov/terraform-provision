export WORKSPACE_DIR=./tmp
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
export AWS_DEFAULT_REGION=us-gov-west-1
export TF_VAR_az1=us-gov-west-1a

export TERRAFORM_PIPELINE_FILE=ci/pipeline.yml
export TERRAFORM_PROVISION_CREDENTIALS_FILE=${WORKSPACE_DIR}/cg-provision.yml

export TF_STATE_BUCKET=$(bosh interpolate ${TERRAFORM_PROVISION_CREDENTIALS_FILE} --path /aws_s3_tfstate_bucket)
export VARZ_BUCKET=cloud-gov-varz
export SEMVER_BUCKET=cg-semver
export BOSH_RELEASES_BUCKET=cloud-gov-bosh-releases

export TOOLING_SECRETS_PASSPHRASE=

export GITHUB_RELEASE_ACCESS_TOKEN=
export SLACK_WEBHOOK_URL=
export NESSUS_KEY=
export NESSUS_SERVER=
export TRIPWIRE_LOCALPASS=
export TRIPWIRE_SITEPASS=
