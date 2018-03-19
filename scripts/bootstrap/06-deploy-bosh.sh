#!/bin/bash

set -eux

# Gather resources for deploy-bosh pipeline
aws s3 cp s3://${TF_STATE_BUCKET}/tooling/state.yml ${WORKSPACE_DIR}/tooling-state.yml

bosh interpolate ${WORKSPACE_DIR}/concourse-environment.yml --path /common_ca_cert_store > ${WORKSPACE_DIR}/ca-cert-store.crt
aws s3 cp ${WORKSPACE_DIR}/ca-cert-store.crt s3://${VARZ_BUCKET}/ca-cert-store.crt --sse AES256

# TODO: rename master-bosh.crt to ca-cert-store.crt in all pipelines (see cg-deploy-bosh)
# * move cp to s3 into secret-rotation/new-ca
# * make new ca-cert-store.crt trigger every deployment
aws s3 cp ${WORKSPACE_DIR}/ca-cert-store.crt s3://${VARZ_BUCKET}/master-bosh.crt --sse AES256

# TODO: Fix worker tagging
cat ../cg-deploy-bosh/ci/pipeline-development.yml | sed 's/\[iaas\]//g' > ${WORKSPACE_DIR}/deploy-bosh-pipeline.yml

if [ ! -f "${WORKSPACE_DIR}/master-bosh-state.json" ]; then
  echo '{}' > ${WORKSPACE_DIR}/master-bosh-state.json
  aws s3 cp ${WORKSPACE_DIR}/master-bosh-state.json s3://${VARZ_BUCKET}/master-bosh-state.json --sse AES256
fi

# Create buckets not managed by terraform
if aws s3 ls "s3://${SEMVER_BUCKET}" 2>&1 | grep -q 'NoSuchBucket' ; then
  aws s3 mb "s3://${SEMVER_BUCKET}"
fi
if aws s3 ls "s3://${BOSH_RELEASES_BLOBSTORE_BUCKET}" 2>&1 | grep -q 'NoSuchBucket' ; then
  aws s3 mb "s3://${BOSH_RELEASES_BLOBSTORE_BUCKET}"
fi

# Set deploy-bosh pipeline
fly --target bootstrap set-pipeline \
  --pipeline deploy-bosh \
  --config ${WORKSPACE_DIR}/deploy-bosh-pipeline.yml \
  --load-vars-from ${WORKSPACE_DIR}/concourse-environment.yml \
  --load-vars-from ../cg-deploy-bosh/ci/concourse-defaults.yml \
  --var aws-region=${AWS_DEFAULT_REGION} \
  --var masterbosh-target=$(bosh interpolate ${WORKSPACE_DIR}/tooling-state.yml --path /terraform_outputs/master_bosh_static_ip) \
  --var toolingbosh-target=$(bosh interpolate ${WORKSPACE_DIR}/tooling-state.yml --path /terraform_outputs/tooling_bosh_static_ip) \
  --var s3-bosh-releases-bucket=${BOSH_RELEASES_BUCKET} \
  --var tf-state-bucket=${TF_STATE_BUCKET} \
  --var secrets-bucket=${VARZ_BUCKET} \
  --var semver-bucket=${SEMVER_BUCKET} \
  --var github-release-access-token=${GITHUB_RELEASE_ACCESS_TOKEN} \
  --var slack-webhook-url=${SLACK_WEBHOOK_URL} \
  --var tooling-secrets-passphrase=${TOOLING_SECRETS_PASSPHRASE} \
  --var nessus-agent-key=${NESSUS_KEY} \
  --var nessus-agent-server=${NESSUS_SERVER} \
  --var tripwire-localpass=${TRIPWIRE_LOCALPASS} \
  --var tripwire-sitepass=${TRIPWIRE_SITEPASS} \
  --var uaa-url-opslogin=https://opslogin.dev2.us-gov-west-1.aws-us-gov.cloud.gov
fly --target bootstrap unpause-pipeline --pipeline deploy-bosh

# Deploy master bosh
fly --target bootstrap trigger-job --job deploy-bosh/deploy-master-bosh --watch

# TODO: Properly bootstrap/upload custom bosh releases.
## Create bosh releases pipeline
#cat ../cg-deploy-bosh/releases/releases.yml | \
#  sed "s/^bosh_release_bucket: .*$/bosh_release_bucket: ${BOSH_RELEASES_BUCKET}/g" | \
#  sed "s/^release_blobstore_bucket: .*$/release_blobstore_bucket: ${BOSH_RELEASES_BLOBSTORE_BUCKET}/g" | \
#  sed "s/^aws_region: .*$/aws_region: ${AWS_DEFAULT_REGION}/g" \
#  > ${WORKSPACE_DIR}/bosh-releases.yml
#
#CI_URL="https://$(cat ${WORKSPACE_DIR}/terraform-outputs.json | jq -r '.public_ip.value'):4443" \
#RELEASES_YAML="${WORKSPACE_DIR}/bosh-releases.yml" \
#  ../cg-deploy-bosh/releases/generate.sh
#
#bosh_releases_pipeline=$(CI_URL="https://$(cat ${WORKSPACE_DIR}/terraform-outputs.json | jq -r '.public_ip.value'):4443" \
#  RELEASES_YAML="${WORKSPACE_DIR}/bosh-releases.yml" \
#  NO_FLY="true" \
#  ../cg-deploy-bosh/releases/generate.sh)
#
#cat ${bosh_releases_pipeline} | sed 's/\[iaas\]//g' > ${WORKSPACE_DIR}/bosh-releases-pipeline.yml
#
## Fly bosh releases pipeline
#fly -t bootstrap set-pipeline --pipeline bosh-releases --config ${WORKSPACE_DIR}/bosh-releases-pipeline.yml
#fly --target bootstrap unpause-pipeline --pipeline bosh-releases
#
## Upload common releases
#fly --target bootstrap trigger-job --job deploy-bosh/common-releases-master --watch
#
## Deploy tooling bosh
#fly --target bootstrap trigger-job --job deploy-bosh/deploy-tooling-bosh --watch
#fly --target bootstrap trigger-job --job deploy-bosh/common-releases-tooling --watch
