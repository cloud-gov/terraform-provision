#!/bin/bash

set -eux

# Create AWS keypair
aws ec2 delete-key-pair --key-name bootstrap
aws ec2 create-key-pair --key-name bootstrap > ${WORKSPACE_DIR}/aws-keypair.json

# Provision terraform infrastructure
terraform init ./terraform/stacks/bootstrap
terraform apply ./terraform/stacks/bootstrap
terraform output -json > ${WORKSPACE_DIR}/terraform-outputs.json
