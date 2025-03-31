#!/bin/sh
set -e
SCRIPTPATH=$( cd "$(dirname "$0")" ; pwd -P )

# Check environment variables
export DATABASES="${DATABASES}"
export STATE_FILE_PATH="${STATE_FILE_PATH}"
export TERRAFORM="${TERRAFORM_BIN:-terraform}"
export TERRAFORM_DB_HOST_FIELD="${DB_HOST}"
export TERRAFORM_DB_USERNAME_FIELD="${DB_USERNAME}"
export TERRAFORM_DB_PASSWORD_FIELD="${DB_PASSWORD}"

"$SCRIPTPATH"/create-and-update-db.sh
