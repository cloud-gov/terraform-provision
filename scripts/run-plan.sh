#!/bin/sh

#
# Run the plan to test any changes to the infrastructure
#
. $(dirname $0)/environment.sh

# for STACK_NAME in `echo "tooling production staging"`
# do
STACK_NAME="tooling"
    rm -rf .terraform
    terraform remote config \
      -backend=s3 \
      -backend-config="bucket=${TF_VAR_remote_state_bucket}" \
      -backend-config="key=${STACK_NAME}/terraform.tfstate"

    terraform get \
      -update \
      ./terraform/stacks/${STACK_NAME}

    terraform plan \
      -refresh=true \
      -var-file=${STACK_NAME}.tfvars \
      ./terraform/stacks/${STACK_NAME}
#done
