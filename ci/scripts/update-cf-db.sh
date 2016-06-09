#!/bin/sh
set -e

# Check environment variables
export PGPASSWORD=${CF_DB_PASSWORD:?}
db_address=$(grep cf_rds_host ${STATE_FILE_PATH} | uniq | cut -d'"' -f4)

# See: https://github.com/koalaman/shellcheck/wiki/SC2086#exceptions
psql_adm() { psql -h "${db_address}" -U cfdb "$@"; }


for db in ccdb uaadb; do

  # Create database
  psql_adm -d postgres -l | grep -q " ${db} " || \
    psql_adm -d postgres -c "CREATE DATABASE ${db} OWNER cfdb"

  # Enable extensions
  for ext in citext uuid-ossp pgcrypto pg_stat_statements; do
    psql_adm -d "${db}" -c "CREATE EXTENSION IF NOT EXISTS ${ext}"
  done

done