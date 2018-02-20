#!/bin/bash

set -eux

fly --target bootstrap login \
  --concourse-url=https://$(cat ${WORKSPACE_DIR}/terraform-outputs.json | jq -r ''):4443 \
  --username bootstrap \
  --password $(bosh interpolate ${WORKSPACE_DIR}/bootstrap-concourse-creds.yml --path /basic-auth-password)

fly --target bootstrap set-pipeline \
  --pipeline terraform-provision \
  --config ci/pipeline.yml \
  --load-vars-from ${TERRAFORM_PROVISION_CREDENTIALS}

fly --target bootstrap trigger-job --job terraform-provision/plan-bootstrap-tooling
