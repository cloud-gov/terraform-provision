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
  # Special case for Shibboelth, create FK between totp_seed and users and CASCADE on delete
  if [ "${db}" = "uaadb" ]; then
    psql_adm -d "${db}" <<-EOT
    BEGIN;
      CREATE TABLE IF NOT EXISTS totp_seed
        (
          username varchar(255) PRIMARY KEY,
          seed varchar(36),
          backup_code varchar(36)
        );
      ALTER TABLE IF EXISTS totp_seed
        DROP CONSTRAINT username_record_keeper;
      ALTER TABLE IF EXISTS totp_seed
        ADD CONSTRAINT username_record_keeper
          FOREIGN KEY (username)
          REFERENCES users (username)
          ON DELETE CASCADE;
    COMMIT;
EOT

    psql_adm -d "${db}" <<-EOT
      CREATE TABLE IF NOT EXISTS storagerecords
        (
          context varchar(255) NOT NULL,
          id varchar(255) NOT NULL,
          expires bigint DEFAULT NULL,
          value text NOT NULL,
          version bigint NOT NULL,
          PRIMARY KEY (context, id)
        )
EOT

    # Enforce cloud.gov origin for IdP users by validating that their username
    # is a valid email address, that their origin is set to `uaa` that they have
    # been verified and that their created date does not match their password
    # last modified date which only occurs for users who have been invited and
    # haven't logged in for the first time and created their password.
    psql_adm -d "${db}" <<-EOT
      BEGIN;
      CREATE OR REPLACE FUNCTION "f_isValidEmail"( text ) RETURNS BOOLEAN AS '
      SELECT \$1 ~ ''^[^@\s]+@[^@\s]+(\.[^@\s]+)+$'' AS RESULT
      ' LANGUAGE sql;
      CREATE OR REPLACE FUNCTION "f_enforceCloudGovOrigin"() RETURNS TRIGGER AS \$\$
      BEGIN
        UPDATE users
          SET ( origin, external_id ) = ( 'cloud.gov', username )
          WHERE "f_isValidEmail"( username ) AND
            origin = 'uaa' AND
            verified = true AND
            created::date != passwd_lastmodified::date;
      END;
      \$\$ LANGUAGE plpgsql;
      COMMIT;
EOT
    psql_adm -d "${db}" <<-EOT
      BEGIN;
      DROP TRIGGER IF EXISTS enforce_cloud_gov_idp_origin_trigger
        ON users;
      CREATE TRIGGER enforce_cloud_gov_idp_origin_trigger
        AFTER UPDATE ON users
        FOR EACH STATEMENT EXECUTE PROCEDURE "f_enforceCloudGovOrigin"();
      COMMIT;
EOT
  fi

done
