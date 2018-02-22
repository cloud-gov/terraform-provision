#!/bin/bash

set -eux

fly --target bootstrap set-pipeline \
  --pipeline deploy-bosh \
  --config ../cg-deploy-bosh/ci/pipeline.yml \
  --load-vars-from ${WORKSPACE_DIR}/concourse-environment.yml \
  --load-vars-from ../cg-deploy-bosh/ci/concourse-defaults.yml \
  --var aws-region=${AWS_DEFAULT_REGION}
fly --target bootstrap unpause-pipeline --pipeline deploy-bosh

fly --target bootstrap trigger-job --job deploy-bosh/deploy-master-bosh --watch
fly --target bootstrap trigger-job --job deploy-bosh/common-releases-master --watch
fly --target bootstrap trigger-job --job deploy-bosh/deploy-tooling-bosh --watch
fly --target bootstrap trigger-job --job deploy-bosh/common-releases-tooling --watch
