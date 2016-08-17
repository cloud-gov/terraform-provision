#!/bin/bash

which terraform > /dev/null 2>&1 || {
  echo "Aborted. Please install terraform by following https://www.terraform.io/intro/getting-started/install.html" 1>&2
  exit 1
}

find ./terraform -name "*.tf" -print0 \
  | xargs -0 -n1 dirname \
  | sort --unique \
  | xargs -I {} terraform validate {}
