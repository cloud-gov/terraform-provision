#!/bin/sh
set -e
SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )

# Check environment variables
export DB_USER="postgres"
export DB_PASSWORD=${BOSH_DB_PASSWORD:?}
export TERRAFORM_DB_FIELD="bosh_rds_host"
export DATABASES="bosh bosh_uaadb"
export STATE_FILE_PATH=${STATE_FILE_PATH}

$SCRIPTPATH/create-and-update-db.sh
