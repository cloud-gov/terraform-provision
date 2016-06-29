#!/bin/sh
set -e

# Check environment variables
export DB_USER="postgres"
export DB_PASSWORD=${BOSH_DB_PASSWORD:?}
export TERRAFORM_DB_FIELD="bosh_rds_host"
export DATABASES="bosh bosh_uaadb"
export STATE_FILE_PATH=${STATE_FILE_PATH}

./create-and-update-db.sh