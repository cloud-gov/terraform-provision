#!/bin/sh

SCRIPT_DIR=$(dirname $0)

. $SCRIPT_DIR/environment.sh

STACK_NAME="bootstrap"
terraform get \
  -update \
  $SCRIPT_DIR/../terraform/stacks/${STACK_NAME}

terraform apply \
  -refresh=true \
  $SCRIPT_DIR/../terraform/stacks/${STACK_NAME}