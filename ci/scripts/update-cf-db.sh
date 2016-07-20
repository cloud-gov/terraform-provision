#!/bin/sh
set -e
SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )

# Check environment variables
export DB_USER="cfdb"
export DB_PASSWORD=${CF_DB_PASSWORD:?}
export TERRAFORM_DB_FIELD="cf_rds_host"
export DATABASES="ccdb uaadb diegodb"
export STATE_FILE_PATH=${STATE_FILE_PATH}

$SCRIPTPATH/create-and-update-db.sh
