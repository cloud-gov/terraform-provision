#!/bin/sh
set -e
set -u

TERRAFORM="${TERRAFORM_BIN:-terraform}"

# Check environment variables
db_address=$(${TERRAFORM} output -raw -state="${STATE_FILE_PATH}" "${TERRAFORM_DB_HOST_FIELD}")
db_user=$(${TERRAFORM} output -raw -state="${STATE_FILE_PATH}" "${TERRAFORM_DB_USERNAME_FIELD}")
db_pass=$(${TERRAFORM} output -raw -state="${STATE_FILE_PATH}" "${TERRAFORM_DB_PASSWORD_FIELD}")

# Any thoughts here?
# There's no way to use an env variable for mysql password, so either
# we specify on command line or we write an options file and read it 
# with --defaults-extra-file=file_name
mysql_adm() { mysql -h "${db_address}" -u "${db_user}" -p"${db_pass}" -e "$@"; }

# SV-235137 etc... for password complexity
# See https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/MySQL.Concepts.PasswordValidationPlugin.html
# Requires restart to take effect, then uses parameter group for tuning
mysql_adm "INSTALL PLUGIN validate_password SONAME 'validate_password.so';"
