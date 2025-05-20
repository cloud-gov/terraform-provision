#!/bin/sh
set -e
SCRIPTPATH=$( cd "$(dirname "$0")" ; pwd -P )

# Check environment variables
export DATABASES="${DATABASES}"
export EXTENSIONS="${CUSTOM_EXTENSIONS:-citext uuid-ossp pgcrypto pg_stat_statements}"
export STATE_FILE_PATH="${STATE_FILE_PATH}"
export TERRAFORM="${TERRAFORM_BIN:-terraform}"
export TERRAFORM_DB_HOST_FIELD="${TERRAFORM_DB_HOST_FIELD}"
export TERRAFORM_DB_USERNAME_FIELD="${TERRAFORM_DB_USERNAME_FIELD}"
export TERRAFORM_DB_PASSWORD_FIELD="${TERRAFORM_DB_PASSWORD_FIELD}"

"$SCRIPTPATH"/create-and-update-db.sh
