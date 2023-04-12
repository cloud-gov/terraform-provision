#!/bin/bash
set -e

which terraform > /dev/null 2>&1 || {
  echo "Aborted. Please install terraform by following https://www.terraform.io/intro/getting-started/install.html" 1>&2
  exit 1
}

echo "Any files that follow were not formatted with terraform fmt:"
terraform fmt -recursive -diff -check
