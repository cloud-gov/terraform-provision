#!/bin/sh
set -e
set -u

# Check environment variables
export PGPASSWORD=${DB_PASSWORD:?}
db_address=$(grep -A 4 "\"${TERRAFORM_DB_FIELD}\"" ${STATE_FILE_PATH} | grep ${STACK_NAME} | uniq | cut -d'"' -f4)

# See: https://github.com/koalaman/shellcheck/wiki/SC2086#exceptions
psql_adm() { psql -h "${db_address}" -U ${DB_USER} "$@"; }


for db in ${DATABASES}; do

  # Create database
  psql_adm -d postgres -l | grep -q " ${db} " || \
    psql_adm -d postgres -c "CREATE DATABASE ${db} OWNER ${DB_USER}"

  # Enable extensions
  for ext in citext uuid-ossp pgcrypto pg_stat_statements; do
    psql_adm -d "${db}" -c "CREATE EXTENSION IF NOT EXISTS \"${ext}\""
  done

  # Special case for uaadb, create totp seed table for use with MFA
  if [ "${db}" = "uaadb" ]; then
    psql_adm -d "${db}" -c "CREATE TABLE IF NOT EXISTS totp_seed ( username varchar(255) PRIMARY KEY, seed varchar(36), backup_code varchar(36) )"
  fi

done
