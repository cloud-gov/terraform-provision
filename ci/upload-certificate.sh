#!/bin/bash

set -eux

export AWS_ACCESS_KEY_ID=$(spruce json terraform-yaml-tooling/state.yml | jq -r ".terraform_outputs.iam_cert_provision_access_key_id_curr")
export AWS_SECRET_ACCESS_KEY=$(spruce json terraform-yaml-tooling/state.yml | jq -r ".terraform_outputs.iam_cert_provision_secret_access_key_curr")

# Upload new certificate if present
if [ -s acme/cert.pem ]; then
  aws iam upload-server-certificate \
    --path "${CERT_PATH}" \
    --server-certificate-name "${CERT_PREFIX}-$(date +%Y-%m-%d-%H-%M)" \
    --certificate-body file://acme/cert.pem \
    --certificate-chain file://acme/chain.pem \
    --private-key file://acme/privkey.pem
fi

# Delete expired certificates
cutoff=$(date --date '-1 month' --iso-8601=seconds --utc | sed 's/+0000$/Z/')
certificates=$(jq -r --arg cutoff "${cutoff}" \
  '.ServerCertificateMetadataList[] | select(.Expiration < $cutoff) | .ServerCertificateName' \
  < certificates/metadata)
for certificate in ${certificates}; do
  aws iam delete-server-certificate --server-certificate-name "${certificate}"
done
