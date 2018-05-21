#!/bin/bash

set -eux

az=$(aws ec2 describe-availability-zones | jq -r '.AvailabilityZones[0].ZoneName')

# Delete bootstrap concourse
bosh delete-env ../concourse-deployment/lite/concourse.yml \
  --state ${WORKSPACE_DIR}/bootstrap-concourse-state.json \
  --vars-store ${WORKSPACE_DIR}/bootstrap-concourse-creds.yml \
  -o ../concourse-deployment/lite/infrastructures/aws.yml \
  -o ./bosh/opsfiles/basic-auth.yml \
  -o ./bosh/opsfiles/self-signed-tls.yml \
  -l ../concourse-deployment/versions.yml \
  -o ./bosh/opsfiles/ssh-tunnel.yml \
  -o ./bosh/opsfiles/vip-network.yml \
  -l ${WORKSPACE_DIR}/aws-variables.yml \
  -v region=${AWS_DEFAULT_REGION} \
  -v default_key_name=bootstrap \
  -v az=${az} \
  -v access_key_id=${AWS_ACCESS_KEY_ID} \
  -v secret_access_key=${AWS_SECRET_ACCESS_KEY}

# Delete AWS keypair
aws ec2 delete-key-pair --key-name bootstrap

# Terraform
terraform destroy ./terraform/stacks/bootstrap
