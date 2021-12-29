#!/bin/bash

set -eux

if [[ -z "${TF_VAR_cert_remote_role_arn}" ]]; then
    echo "you must set TF_VAR_remote_role_arn"
    echo "check the README for more info"
    exit 1
fi

mkdir -p ${WORKSPACE_DIR}
TF="terraform -chdir=./terraform/stacks/managedaccount"
# Provision terraform infrastructure
${TF} init
${TF} validate 
${TF} apply
${TF} output -json > ${WORKSPACE_DIR}/terraform-outputs.json
