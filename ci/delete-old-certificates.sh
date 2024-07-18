#!/bin/bash

set -eux

export AWS_ACCESS_KEY_ID=$(spruce json terraform-yaml-tooling/state.yml | jq -r ".terraform_outputs.iam_cert_provision_access_key_id_curr")
export AWS_SECRET_ACCESS_KEY=$(spruce json terraform-yaml-tooling/state.yml | jq -r ".terraform_outputs.iam_cert_provision_secret_access_key_curr")

if [[ -n "${ASSUME_ROLE_ARN}" ]]; then
  read access_key_id secret_access_key session_token < <(echo $(aws sts assume-role --role-arn=${ASSUME_ROLE_ARN} --role-session-name=concourse_cert_upload | jq -r '.Credentials.AccessKeyId, .Credentials.SecretAccessKey, .Credentials.SessionToken'))
  export AWS_ACCESS_KEY_ID="${access_key_id}"
  export AWS_SECRET_ACCESS_KEY="${secret_access_key}"
  export AWS_SESSION_TOKEN="${session_token}"
fi

# Delete expired certificates
cutoff=$(date --date '-1 month' --iso-8601=seconds --utc | sed 's/+0000$/Z/')
certificates=$(jq -r --arg cutoff "${cutoff}" \
  '.ServerCertificateMetadataList[] | select(.Expiration < $cutoff) | .ServerCertificateName' \
  < certificates/metadata)
for certificate in ${certificates}; do
  aws iam delete-server-certificate --server-certificate-name "${certificate}"
done
