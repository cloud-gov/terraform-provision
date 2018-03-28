#!/bin/bash

set -eux

# Get CA cert for bootstrap concourse
bosh interpolate ${WORKSPACE_DIR}/bootstrap-concourse-creds.yml --path /bootstrap-ca/ca > ${WORKSPACE_DIR}/bootstrap-ca.crt

# Login to bootstrap concourse
fly --target bootstrap login \
  --concourse-url=https://$(cat ${WORKSPACE_DIR}/terraform-outputs.json | jq -r '.public_ip.value'):4443 \
  --ca-cert ${WORKSPACE_DIR}/bootstrap-ca.crt \
  --username bootstrap \
  --password $(bosh interpolate ${WORKSPACE_DIR}/bootstrap-concourse-creds.yml --path /basic-auth-password)

fly --target bootstrap sync

# TODO: Fix worker tagging
bosh int ${TERRAFORM_PIPELINE_FILE} --ops-file bosh/opsfiles/development.yml | sed 's/\[iaas\]//g' > ${WORKSPACE_DIR}/cg-provision-pipeline.yml

# Set terraform-provision pipeline
fly --target bootstrap set-pipeline \
  --pipeline terraform-provision \
  --config ${WORKSPACE_DIR}/cg-provision-pipeline.yml \
  --load-vars-from ci/concourse-defaults.yml \
  --load-vars-from ${TERRAFORM_PROVISION_CREDENTIALS_FILE}
fly --target bootstrap unpause-pipeline --pipeline terraform-provision

# Ensure tf has a bucket for state
if aws s3 ls s3://${TF_STATE_BUCKET} 2>&1 | grep -q 'NoSuchBucket' ; then
  aws s3 mb s3://${TF_STATE_BUCKET}
fi
aws s3api put-bucket-versioning --bucket "${TF_STATE_BUCKET}" --versioning-configuration Status=Enabled

# Plan tooling environment
fly --target bootstrap trigger-job --job terraform-provision/plan-bootstrap-tooling --watch
