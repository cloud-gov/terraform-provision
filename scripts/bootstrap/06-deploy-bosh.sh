#!/bin/bash

set -eux

fly --target bootstrap set-pipeline \
  --pipeline deploy-bosh \
  --config ../cg-deploy-bosh/ci/pipeline.yml \
  --load-vars-from ${WORKSPACE_DIR}/concourse-environment.yml \
  --load-vars-from ../cg-deploy-bosh/ci/concourse-defaults.yml

fly --target bootstrap trigger-job --job deploy-bosh/deploy-master-bosh
fly --target bootstrap trigger-job --job deploy-bosh/common-releases-master
fly --target bootstrap trigger-job --job deploy-bosh/deploy-tooling-bosh
fly --target bootstrap trigger-job --job deploy-bosh/common-releases-tooling
