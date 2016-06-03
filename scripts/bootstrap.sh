#!/bin/sh


if [ "X$1" = "Xapply" ] || [ "X$1" = "Xdestroy" ] || [ "X$1" = "Xplan" ]; then

    OPTIONS="-refresh"
    if [ "X$1" = "Xdestroy" ]; then
        OPTIONS="-force"
    fi

    SCRIPT_DIR=$(dirname $0)
    . $SCRIPT_DIR/environment.sh
    STACK_NAME="bootstrap"

    terraform get \
      -update \
      $SCRIPT_DIR/../terraform/stacks/${STACK_NAME}

    terraform $1 \
      $OPTIONS \
      $SCRIPT_DIR/../terraform/stacks/${STACK_NAME}

else
    echo "Must specify either 'plan', 'apply' or 'destroy'"
    exit 1
fi