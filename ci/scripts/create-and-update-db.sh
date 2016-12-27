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
  # Special case for Shibboleth, create storage records table for use with multi-zone Shibboleth
  # Special case for Shibboleth, create function and trigger that verifies origin uaa is set to cloud.gov IdP
  if [ "${db}" = "uaadb" ]; then
    psql_adm -d "${db}" -c "CREATE TABLE IF NOT EXISTS totp_seed ( username varchar(255) PRIMARY KEY, seed varchar(36), backup_code varchar(36) )"
    psql_adm -d "${db}" -c "CREATE TABLE IF NOT EXISTS storagerecords ( context varchar(255) NOT NULL, id varchar(255) NOT NULL, expires bigint DEFAULT NULL, value text NOT NULL, version bigint NOT NULL, PRIMARY KEY (context, id) )"

    psql_adm -d "${db}" -c << EOT
      CREATE OR REPLACE FUNCTION "f_isValidEmail"( text ) RETURNS BOOLEAN AS '
      SELECT $1 ~ ''^[^@\s]+@[^@\s]+(\.[^@\s]+)+$'' AS RESULT
      ' LANGUAGE sql
EOT
    psql_adm -d "${db}" -c << EOT
      CREATE OR REPLACE FUNCTION "f_enforceCloudGovOrigin"( text ) RETURNS TRIGGER AS $$
      BEGIN
        UPDATE users
          SET ( origin, external_id ) = ( 'cloud.gov', username )
          WHERE "f_isValidEmail"( username ) AND
            origin = 'uaa' AND
            verified = true AND
            created::date != passwd_lastmodified::date;
      END;
      $$ LANGUAGE plpgsql
EOT
    psql_adm -d "${db}" -c << EOT
      CREATE TRIGGER enforce_cloud_gov_idp_origin_trigger
        AFTER UPDATE ON users
        FOR EACH STATEMENT EXECUTE PROCEDURE "f_enforceCloudGovOrigin"()
EOT
  fi

done
