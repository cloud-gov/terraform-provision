#!/bin/bash

set -eux

export TF_VAR_az1="us-gov-west-1a"

workspace=$(mktemp -d)

aws ec2 delete-key-pair --key-name bootstrap
aws ec2 create-key-pair --key-name bootstrap > ${workspace}/aws-keypair.json

# Provision terraform infrastructure
terraform init ./terraform/stacks/bootstrap
terraform apply ./terraform/stacks/bootstrap
terraform output -json > ${workspace}/terraform-outputs.json

# Collect AWS variables
bosh interpolate \
  ./bosh/varsfiles/collect-aws-variables.yml \
  -l ${workspace}/terraform-outputs.json \
  -l ${workspace}/aws-keypair.json \
  > ${workspace}/aws-variables.yml

# Deploy bootstrap concourse
bosh create-env ../concourse-deployment/lite/concourse.yml \
  --state bootstrap-concourse-state.json \
  --vars-store ${workspace}/bootstrap-concourse-creds.yml \
  -o ../concourse-deployment/lite/infrastructures/aws.yml \
  -o ./bosh/opsfiles/basic-auth.yml \
  -o ./bosh/opsfiles/self-signed-tls.yml \
  -l ../concourse-deployment/versions.yml \
  -o ./bosh/opsfiles/ssh-tunnel.yml \
  -o ./bosh/opsfiles/vip-network.yml \
  -l ${workspace}/aws-variables.yml \
  -v region=${AWS_DEFAULT_REGION} \
  -v default_key_name=bootstrap \
  -v az=${TF_VAR_az1} \
  -v access_key_id=${AWS_ACCESS_KEY_ID} \
  -v secret_access_key=${AWS_SECRET_ACCESS_KEY}
