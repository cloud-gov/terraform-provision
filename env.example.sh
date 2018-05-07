export WORKSPACE_DIR=./tmp
export AWS_ACCESS_KEY_ID="XXX"
export AWS_SECRET_ACCESS_KEY="XXX"
export AWS_DEFAULT_REGION=us-gov-west-1
export TF_VAR_az1=us-gov-west-1a

# What environment we are deploying to (currently should only be development or production)
export DEPLOY_ENV="XXX"

# what pipeline to launch
export TERRAFORM_PIPELINE_FILE=ci/pipeline.yml

# Uncomment these after you've generated the TERRAFORM_PROVISION_CREDENTIALS_FILE
# and before step 03
#export TERRAFORM_PROVISION_CREDENTIALS_FILE=${WORKSPACE_DIR}/cg-provision.yml
#export TF_STATE_BUCKET=$(bosh interpolate ${TERRAFORM_PROVISION_CREDENTIALS_FILE} --path /aws_s3_tfstate_bucket)

export VARZ_BUCKET=cloud-gov-varz
export SEMVER_BUCKET=cg-semver
export BOSH_RELEASES_BUCKET=cloud-gov-bosh-releases
export BOSH_RELEASES_BLOBSTORE_BUCKET=cloud-gov-release-blobstore
export TOOLING_SECRETS_PASSPHRASE="XXX"
export CONCOURSE_SECRETS_PASSPHRASE="XXX"
export SLACK_WEBHOOK_URL="XXX"
export NESSUS_KEY="XXX"
export NESSUS_SERVER="XXX"
export TRIPWIRE_LOCALPASS="XXX"
export TRIPWIRE_SITEPASS="XXX"
