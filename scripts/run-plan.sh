#!/bin/sh

#
# Run the plan to test any changes to the infrastructure
#
# environment.sh doesn't exist when shellcheck runs, but will when the script runs
# shellcheck disable=SC1091
. "$(dirname "$0")"/environment.sh

for STACK_NAME in tooling production staging
do
#STACK_NAME="tooling"
    rm -rf .terraform
    # trust that TF_VAR_remote_state_bucket will exist
    # shellcheck disable=SC2154
    terraform remote config \
      -backend=s3 \
      -backend-config="bucket=${TF_VAR_remote_state_bucket}" \
      -backend-config="key=${STACK_NAME}/terraform.tfstate"

    terraform get \
      -update \
      ./terraform/stacks/"${STACK_NAME}"

    terraform plan \
      -refresh=true \
      -var-file="${STACK_NAME}".tfvars \
      ./terraform/stacks/"${STACK_NAME}"
done
