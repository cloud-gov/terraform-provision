#!/bin/bash

which terraform > /dev/null 2>&1 || {
  echo "Aborted. Please install terraform by following https://www.terraform.io/intro/getting-started/install.html" 1>&2
  exit 1
}

path="$(dirname $0)"
dirs=$(find "${path}/terraform/stacks" -mindepth 1 -maxdepth 1 -type d)
status=0

for dir in $dirs; do
  echo "Validating terraform directory $dir"
  terraform validate -check-variables=false ${dir} || status=1
done

exit ${status}
