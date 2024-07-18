#!/bin/bash

which terraform > /dev/null 2>&1 || {
  echo "Aborted. Please install terraform by following https://www.terraform.io/intro/getting-started/install.html" 1>&2
  exit 1
}

path="$(dirname "$0")"
dirs=$(find "${path}/terraform/stacks" -mindepth 1 -maxdepth 1 -type d)
status=0

TERRAFORM="${TERRAFORM_BIN:-terraform}"

for dir in $dirs; do
  pushd "${dir}" || return
  echo "Validating terraform directory $dir"
  AWS_DEFAULT_REGION=us-gov-west-1 ${TERRAFORM} init -backend=false
  AWS_DEFAULT_REGION=us-gov-west-1 ${TERRAFORM} validate || status=1
  popd || return
done

exit ${status}
