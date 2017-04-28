#!/bin/sh
set -e
set -u

# Check environment variables
db_address=$(terraform output -state=${STATE_FILE_PATH} ${TERRAFORM_DB_HOST_FIELD})
db_user=$(terraform output -state=${STATE_FILE_PATH} ${TERRAFORM_DB_USERNAME_FIELD})
db_pass=$(terraform output -state=${STATE_FILE_PATH} ${TERRAFORM_DB_PASSWORD_FIELD})

export PGPASSWORD=${db_pass:?}

# See: https://github.com/koalaman/shellcheck/wiki/SC2086#exceptions
psql_adm() { psql -h "${db_address}" -U ${db_user} "$@"; }

# contains(string, substring)
# See: http://stackoverflow.com/questions/2829613/how-do-you-tell-if-a-string-contains-another-string-in-unix-shell-scripting
# Returns 0 if the specified string contains the specified substring,
# otherwise returns 1.
contains() {
    string="$1"
    substring="$( printf '%q' "$2" )"
    if test "${string#*$substring}" != "$string"
    then
        return 0    # $substring is in $string
    else
        return 1    # $substring is not in $string
    fi
}

if ! contains "$DATABASES" "$db_user"; then
  DATABASES="$db_user $DATABASES"
fi

for db in ${DATABASES}; do

  # Create database
  psql_adm -d postgres -l | grep -q " ${db} " || \
    psql_adm -d postgres -c "CREATE DATABASE ${db} OWNER ${db_user}"

  # Enable extensions
  for ext in citext uuid-ossp pgcrypto pg_stat_statements; do
    psql_adm -d "${db}" -c "CREATE EXTENSION IF NOT EXISTS \"${ext}\""
  done

  # Remove default privileges
  psql_adm -d "${db}" -c "REVOKE ALL ON SCHEMA public FROM PUBLIC"

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
        DROP CONSTRAINT IF EXISTS username_record_keeper;
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
            verified = true;
        RETURN null;
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
        FOR EACH ROW
        WHEN ( OLD.passwd_lastmodified IS DISTINCT FROM NEW.passwd_lastmodified )
        EXECUTE PROCEDURE "f_enforceCloudGovOrigin"();
      COMMIT;
EOT
  fi

done
