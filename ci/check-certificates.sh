#!/bin/bash

set -eux

export AWS_ACCESS_KEY_ID=$(spruce json terraform-yaml-tooling/state.yml | jq -r ".terraform_outputs.iam_cert_provision_access_key_id_curr")
export AWS_SECRET_ACCESS_KEY=$(spruce json terraform-yaml-tooling/state.yml | jq -r ".terraform_outputs.iam_cert_provision_secret_access_key_curr")

aws iam list-server-certificates \
  --path-prefix "${CERT_PATH}" \
  --no-paginate \
  > certificates/metadata
