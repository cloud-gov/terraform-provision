#!/bin/bash

set -eux

# Set deploy-concourse pipeline
fly --target bootstrap set-pipeline \
  --pipeline deploy-concourse \
  --config ../cg-deploy-concourse/ci/pipeline-development.yml \
  --load-vars-from ${WORKSPACE_DIR}/concourse-environment.yml \
  --load-vars-from ../cg-deploy-concourse/ci/concourse-defaults.yml \
  --var secrets-bucket=${VARZ_BUCKET} \
  --var concourse-production-deployment-bosh-target=$(bosh interpolate ${WORKSPACE_DIR}/tooling-state.yml --path /terraform_outputs/tooling_bosh_static_ip) \
  --var concourse-production-private-passphrase=${CONCOURSE_SECRETS_PASSPHRASE} \
  --var tf-state-bucket=${TF_STATE_BUCKET} \
  --var slack-webhook-url=${SLACK_WEBHOOK_URL} \
  --var concourse-config-git-branch=concourse-defaults
fly --target bootstrap unpause-pipeline --pipeline deploy-concourse

# Deploy concourse
fly --target bootstrap trigger-job --job deploy-concourse/deploy-concourse-production --watch

