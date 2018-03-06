#!/bin/bash

set -eux

# Generate passphrases for encrypted secrets
bosh interpolate ./bosh/varsfiles/secret-rotation.yml \
  --vars-store ${WORKSPACE_DIR}/secret-rotation.yml

# TODO: Fix worker tagging
# TODO: Separate dev pipeline
cat ../cg-secret-rotation/ci/pipeline.yml | sed 's/\[iaas\]//g' > ${WORKSPACE_DIR}/secret-rotation-pipeline.yml

# TODO: Move BOSH secrets bucket(s) into terraform
# Ensure BOSH secrets bucket
if aws s3 ls "s3://${VARZ_BUCKET}" 2>&1 | grep -q 'NoSuchBucket' ; then
  aws s3 mb "s3://${VARZ_BUCKET}"
fi
aws s3api put-bucket-versioning --bucket "${VARZ_BUCKET}" --versioning-configuration Status=Enabled

# Create dummy common secrets files so that we can check resources
for environment in common master tooling; do
  echo '{}' > ${WORKSPACE_DIR}/${environment}-secrets-dummy.yml
  INPUT_FILE=${WORKSPACE_DIR}/${environment}-secrets-dummy.yml \
    OUTPUT_FILE=${WORKSPACE_DIR}/${environment}-secrets-dummy-encrypted.yml \
    PASSPHRASE=$(bosh interpolate ${WORKSPACE_DIR}/secret-rotation.yml --path /${environment}-secrets-passphrase) \
    ../cg-pipeline-tasks/encrypt.sh
  aws s3 cp ${WORKSPACE_DIR}/${environment}-secrets-dummy-encrypted.yml \
    s3://${VARZ_BUCKET}/secrets-${environment}.yml \
    --sse AES256
done

# Set secret-rotation pipeline
fly --target bootstrap set-pipeline \
  --pipeline secret-rotation \
  --config ${WORKSPACE_DIR}/secret-rotation-pipeline.yml \
  --load-vars-from ${WORKSPACE_DIR}/secret-rotation.yml \
  --load-vars-from ../cg-secret-rotation/ci/concourse-defaults.yml \
  --var aws-region=${AWS_DEFAULT_REGION} \
  --var tf-state-bucket=${TF_STATE_BUCKET} \
  --var common-bucket-name=${VARZ_BUCKET} \
  --var master-bucket-name=${VARZ_BUCKET} \
  --var tooling-bucket-name=${VARZ_BUCKET} \
  --var secret-rotation-git-branch=generate-straggler-passwords \
  --var bosh-git-branch=concourse-defaults \
  --var generate-passphrase="true" \
  --var generate-postgres-passphrase="true" \
  --var generate-mbus-passphrase="true" \
  --var generate-vcap-passphrase="true"
fly --target bootstrap unpause-pipeline --pipeline secret-rotation

# TODO: Remove double new-ca once we're sure ca-cert-store.crt works as intended
fly --target bootstrap trigger-job --job secret-rotation/new-ca --watch
fly --target bootstrap trigger-job --job secret-rotation/new-ca --watch
fly --target bootstrap trigger-job --job secret-rotation/update-certificates-bosh-master --watch
fly --target bootstrap trigger-job --job secret-rotation/update-certificates-bosh-tooling --watch

# Pull down secrets for use in deploy-bosh pipeline
CG_PIPELINE=../cg-pipeline-tasks \
  SECRETS_BUCKET=${VARZ_BUCKET} \
  CI_ENV=bootstrap \
  ENVIRONMENTS="common master tooling" \
  ../cg-scripts/generate-concourse-environment.sh
mv concourse-environment.yml ${WORKSPACE_DIR}
