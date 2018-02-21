#!/bin/bash

set -eux

bosh interpolate ./bosh/varsfiles/secret-rotation \
  --vars-store ${WORKSPACE_DIR}/secret-rotation.yml

fly --target bootstrap set-pipeline \
  --pipeline secret-rotation \
  --config ../cg-secret-rotation/ci/pipeline.yml \
  --load-vars-from ${WORKSPACE_DIR}/secret-rotation.yml \
  --load-vars-from ../cg-secret-rotation/ci/concourse-defaults.yml \
  --var aws-region=${AWS_DEFAULT_REGION} \
  --var tf-state-bucket=${TF_STATE_BUCKET} \
  --var common-bucket-name=${VARZ_BUCKET} \
  --var master-bucket-name=${VARZ_BUCKET} \
  --var tooling-bucket-name=${VARZ_BUCKET}

fly --target bootstrap trigger-job --job secret-rotation/new-ca --watch
fly --target bootstrap trigger-job --job secret-rotation/update-certificates-bosh-master --watch
fly --target bootstrap trigger-job --job secret-rotation/update-certificates-bosh-tooling --watch

CG_PIPELINE=../cg-pipeline-tasks \
  SECRETS_BUCKET=${VARZ_BUCKET} \
  CI_ENV=bootstrap \
  ENVIRONMENTS="common master tooling" \
  ../cg-scripts/generate-concourse-environment.sh
mv concourse-environment.yml ${WORKSPACE_DIR}
