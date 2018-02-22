#!/bin/bash

set -eux

bosh interpolate ${WORKSPACE_DIR}/bootstrap-concourse-creds.yml --path /bootstrap-ca/ca > ${WORKSPACE_DIR}/bootstrap-ca.crt

fly --target bootstrap login \
  --concourse-url=https://$(cat ${WORKSPACE_DIR}/terraform-outputs.json | jq -r '.public_ip.value'):4443 \
  --ca-cert ${WORKSPACE_DIR}/bootstrap-ca.crt \
  --username bootstrap \
  --password $(bosh interpolate ${WORKSPACE_DIR}/bootstrap-concourse-creds.yml --path /basic-auth-password)

fly --target bootstrap sync

# TODO: Fix worker tagging
cat ${TERRAFORM_PIPELINE_FILE} | sed 's/\[iaas\]//g' > ${WORKSPACE_DIR}/cg-provision-pipeline.yml

fly --target bootstrap set-pipeline \
  --pipeline terraform-provision \
  --config ${WORKSPACE_DIR}/cg-provision-pipeline.yml \
  --load-vars-from ${TERRAFORM_PROVISION_CREDENTIALS_FILE}
fly --target bootstrap unpause-pipeline --pipeline terraform-provision

# ensure tf has a bucket for state
state_bucket=$(bosh interpolate ${TERRAFORM_PROVISION_CREDENTIALS_FILE} --path /aws_s3_tfstate_bucket)
if aws s3 ls s3://${state_bucket} 2>&1 | grep -q 'NoSuchBucket' ; then
  aws s3 mb s3://${state_bucket}
fi
aws s3api put-bucket-versioning --bucket "${state_bucket}" --versioning-configuration Status=Enabled

fly --target bootstrap trigger-job --job terraform-provision/plan-bootstrap-tooling --watch
