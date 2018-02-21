#!/bin/bash

set -eux

bosh interpolate ./bosh/varsfiles/secret-rotation.yml \
  --vars-store ${WORKSPACE_DIR}/secret-rotation.yml

# TODO: Fix worker tagging
# TODO: Separate dev pipeline
cat ../cg-secret-rotation/ci/pipeline.yml | sed 's/\[iaas\]//g' > ${WORKSPACE_DIR}/secret-rotation-pipeline.yml

fly --target bootstrap set-pipeline \
  --pipeline secret-rotation \
  --config ${WORKSPACE_DIR}/secret-rotation-pipeline.yml \
  --load-vars-from ${WORKSPACE_DIR}/secret-rotation.yml \
  --load-vars-from ../cg-secret-rotation/ci/concourse-defaults.yml \
  --var aws-region=${AWS_DEFAULT_REGION} \
  --var tf-state-bucket=${TF_STATE_BUCKET} \
  --var common-bucket-name=${VARZ_BUCKET} \
  --var master-bucket-name=${VARZ_BUCKET} \
  --var tooling-bucket-name=${VARZ_BUCKET}
fly --target bootstrap unpause-pipeline --pipeline secret-rotation

fly --target bootstrap trigger-job --job secret-rotation/new-ca --watch
fly --target bootstrap trigger-job --job secret-rotation/update-certificates-bosh-master --watch
fly --target bootstrap trigger-job --job secret-rotation/update-certificates-bosh-tooling --watch

# TODO: Move BOSH secrets bucket(s) into terraform
# Ensure BOSH secrets bucket
if aws s3 ls "s3://${VARZ_BUCKET}" 2>&1 | grep -q 'NoSuchBucket' ; then
  aws s3 mb "s3://${VARZ_BUCKET}"
fi

CG_PIPELINE=../cg-pipeline-tasks \
  SECRETS_BUCKET=${VARZ_BUCKET} \
  CI_ENV=bootstrap \
  ENVIRONMENTS="common master tooling" \
  ../cg-scripts/generate-concourse-environment.sh
mv concourse-environment.yml ${WORKSPACE_DIR}
