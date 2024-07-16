#!/bin/sh
set -e
SCRIPTPATH=$( cd "$(dirname "$0")" ; pwd -P )

# Check environment variables
export DATABASES="bosh bosh_uaadb"
export STATE_FILE_PATH="${STATE_FILE_PATH}"
export TERRAFORM="${TERRAFORM_BIN:-terraform}"
export TERRAFORM_DB_HOST_FIELD="bosh_rds_host_curr"
export TERRAFORM_DB_USERNAME_FIELD="bosh_rds_username"
export TERRAFORM_DB_PASSWORD_FIELD="bosh_rds_password"

"$SCRIPTPATH"/create-and-update-db.sh
