#!/bin/sh
set -e

# Check environment variables
export DB_USER="cfdb"
export DB_PASSWORD=${CF_DB_PASSWORD:?}
export TERRAFORM_DB_FIELD="cf_rds_host"
export DATABASES="ccdb uaadb"
export STATE_FILE_PATH=${STATE_FILE_PATH}

./create-and-update-db.sh