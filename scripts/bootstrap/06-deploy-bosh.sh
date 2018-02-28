#!/bin/bash

set -eux

aws s3 cp s3://${TF_STATE_BUCKET}/tooling/state.yml ${WORKSPACE_DIR}/tooling-state.yml

if [ ! -f "${WORKSPACE_DIR}/master-bosh-state.json" ]; then
  echo '{}' > ${WORKSPACE_DIR}/master-bosh-state.json
  aws s3 cp ${WORKSPACE_DIR}/master-bosh-state.json s3://${VARZ_BUCKET}/master-bosh-state.json --sse AES256
fi

bosh interpolate ${WORKSPACE_DIR}/concourse-environment.yml --path /common_ca_cert_store > ${WORKSPACE_DIR}/ca-cert-store.crt
aws s3 cp ${WORKSPACE_DIR}/ca-cert-store.crt s3://${VARZ_BUCKET}/ca-cert-store.crt --sse AES256

# TODO: rename master-bosh.crt to ca-cert-store.crt in all pipelines (see cg-deploy-bosh)
# * move cp to s3 into secret-rotation/new-ca
# * make new ca-cert-store.crt trigger every deployment
aws s3 cp ${WORKSPACE_DIR}/ca-cert-store.crt s3://${VARZ_BUCKET}/master-bosh.crt --sse AES256

cat ../cg-deploy-bosh/ci/pipeline-development.yml | sed 's/\[iaas\]//g' > ${WORKSPACE_DIR}/deploy-bosh-pipeline.yml

if aws s3 ls "s3://${SEMVER_BUCKET}" 2>&1 | grep -q 'NoSuchBucket' ; then
  aws s3 mb "s3://${SEMVER_BUCKET}"
fi

fly --target bootstrap set-pipeline \
  --pipeline deploy-bosh \
  --config ${WORKSPACE_DIR}/deploy-bosh-pipeline.yml \
  --load-vars-from ${WORKSPACE_DIR}/concourse-environment.yml \
  --load-vars-from ../cg-deploy-bosh/ci/concourse-defaults.yml \
  --var aws-region=${AWS_DEFAULT_REGION} \
  --var masterbosh-target=$(bosh interpolate ${WORKSPACE_DIR}/tooling-state.yml --path /terraform_outputs/master_bosh_static_ip) \
  --var toolingbosh-target=$(bosh interpolate ${WORKSPACE_DIR}/tooling-state.yml --path /terraform_outputs/tooling_bosh_static_ip) \
  --var s3-bosh-releases-bucket=${BOSH_RELEASES_BUCKET} \
  --var tf-state-bucket-tooling=${TF_STATE_BUCKET} \
  --var tf-state-bucket-production=${TF_STATE_BUCKET} \
  --var tf-state-bucket-staging=${TF_STATE_BUCKET} \
  --var tf-state-bucket-development=${TF_STATE_BUCKET} \
  --var production-bucket-name=${VARZ_BUCKET} \
  --var tooling-bucket-name=${VARZ_BUCKET} \
  --var master-bucket-name=${VARZ_BUCKET} \
  --var common-bucket-name=${VARZ_BUCKET} \
  --var semver-bucket=${SEMVER_BUCKET} \
  --var github-release-access-token=${GITHUB_RELEASE_ACCESS_TOKEN} \
  --var slack-webhook-url=${SLACK_WEBHOOK_URL} \
  --var tooling-secrets-passphrase=${TOOLING_SECRETS_PASSPHRASE} \
  --var nessus-agent-key=${NESSUS_KEY} \
  --var nessus-agent-server=${NESSUS_SERVER} \
  --var tripwire-localpass=${TRIPWIRE_LOCALPASS} \
  --var tripwire-sitepass=${TRIPWIRE_SITEPASS} \
  --var bosh-config-git-branch=concourse-defaults
fly --target bootstrap unpause-pipeline --pipeline deploy-bosh

fly --target bootstrap trigger-job --job deploy-bosh/deploy-master-bosh --watch
fly --target bootstrap trigger-job --job deploy-bosh/common-releases-master --watch
fly --target bootstrap trigger-job --job deploy-bosh/deploy-tooling-bosh --watch
fly --target bootstrap trigger-job --job deploy-bosh/common-releases-tooling --watch
