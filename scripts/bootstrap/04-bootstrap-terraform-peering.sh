#!/bin/bash

set -eux

# Now that tooling stack exists, reapply boostrap stack to create peering connection
# between bootstrap and tooling
export TF_VAR_use_vpc_peering="1"
export TF_VAR_tooling_state_bucket="${TOOLING_STATE_BUCKET}"

terraform apply ./terraform/stacks/bootstrap
