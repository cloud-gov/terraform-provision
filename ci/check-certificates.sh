#!/bin/bash

set -eu

export AWS_ACCESS_KEY_ID=$(spruce json terraform-yaml-tooling/state.yml | jq -r ".terraform_outputs.iam_cert_provision_access_key_id_curr")
export AWS_SECRET_ACCESS_KEY=$(spruce json terraform-yaml-tooling/state.yml | jq -r ".terraform_outputs.iam_cert_provision_secret_access_key_curr")

if [[ -n "${ASSUME_ROLE_ARN}" ]]; then
  read access_key_id secret_access_key < <(echo $(aws sts assume-role --role-arn=${ASSUME_ROLE_ARN} --role-session-name=concourse_cert_upload | jq -r '.Credentials.AccessKeyId .Credentials.SecretAccessKey'))
  export AWS_ACCESS_KEY_ID=${access_key_id}
  export AWS_SECRET_ACCESS_KEY=${secret_access_key}
fi

aws iam list-server-certificates \
  --path-prefix "${CERT_PATH}" \
  --no-paginate \
  > certificates/metadata
