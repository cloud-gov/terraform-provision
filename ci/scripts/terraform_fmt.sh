#!/bin/bash
set -e

which terraform > /dev/null 2>&1 || {
  echo "Aborted. Please install terraform by following https://www.terraform.io/intro/getting-started/install.html" 1>&2
  exit 1
}

pwd
terraform fmt -recursive
git diff-index --quiet HEAD -- # exit 1 if dirty, 0 otherwise
