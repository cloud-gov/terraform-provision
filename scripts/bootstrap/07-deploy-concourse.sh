#!/bin/bash

set -eux

fly --target bootstrap set-pipeline \
  --pipeline deploy-concourse \
  --config ../cg-deploy-concourse/ci/pipeline.yml \
  --load-vars-from ${WORKSPACE_DIR}/concourse-environment.yml \
  --load-vars-from ../cg-deploy-concourse/ci/concourse-defaults.yml
fly --target bootstrap unpause-pipeline --pipeline deploy-concourse

fly --target bootstrap trigger-job --job deploy-concourse/deploy-concourse-staging --watch
fly --target bootstrap trigger-job --job deploy-concourse/deploy-concourse-production --watch
