#!/bin/bash

set -eux

curl -L -o jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
chmod +x ./jq

pip install awscli certbot certbot-dns-route53

spruce_url=$(curl https://api.github.com/repos/geofffranks/spruce/releases/latest \
  | ./jq -r '.assets[] | select(.name == "spruce-linux-amd64") | .browser_download_url')
curl -L -o spruce "${spruce_url}"
chmod +x ./spruce

export AWS_ACCESS_KEY_ID=$(./spruce json terraform-yaml/state.yml | ./jq -r ".terraform_outputs.lets_encrypt_access_key_id_curr")
export AWS_SECRET_ACCESS_KEY=$(./spruce json terraform-yaml/state.yml | ./jq -r ".terraform_outputs.lets_encrypt_secret_access_key_curr")

# Quit if current certificate isn't close to expiration date
expiration=$(
  aws iam list-server-certificates \
    --path-prefix "${CERT_PATH}" \
    --no-paginate \
  | ./jq -r '.ServerCertificateMetadataList | sort_by(.Expiration) | .[-1].Expiration')
if [ $(date -d "+14 days" +%s) -lt $(date -d "${expiration}" +%s) ]; then
  exit 0
fi

config_path=$(pwd)

certbot certonly \
  -n --agree-tos \
  --server "${ACME_SERVER:-https://acme-staging-v02.api.letsencrypt.org/directory}" \
  --dns-route53 \
  --config-dir "${config_path}" \
  --email "${EMAIL}" \
  --domain "${DOMAIN}"

out_path=$(ls "${config_path}/live")

aws iam upload-server-certificate \
  --path "${CERT_PATH}" \
  --server-certificate-name "${CERT_PREFIX}-$(date +%Y-%m-%d)" \
  --certificate-body "file://${out_path}/cert.pem" \
  --certificate-chain "file://${out_path}/chain.pem" \
  --private-key "file://${out_path}/privkey.pem"
