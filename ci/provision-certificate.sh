#!/bin/bash

set -eu

curl -L -o jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
chmod +x ./jq

pip install certbot certbot-dns-route53

#spruce_url=$(curl https://api.github.com/repos/geofffranks/spruce/releases/latest \
#  | ./jq -r '.assets[] | select(.name == "spruce-linux-amd64") | .browser_download_url')
#curl -L -o spruce "${spruce_url}"
curl -L -o spruce https://github.com/geofffranks/spruce/releases/download/v1.29.0/spruce-linux-amd64
chmod +x ./spruce

# Quit if current certificate isn't close to expiration date
expiration=$(
  ./jq -r --arg prefix "${CERT_PREFIX}-" \
    '.ServerCertificateMetadataList | map(select(.ServerCertificateName | startswith($prefix))) | sort_by(.Expiration) | .[-1].Expiration' \
    < certificates/metadata)
if [[ $(date --date "+30 days" +%s) -lt $(date --date "${expiration}" +%s) ]]; then
  exit 0
fi

config_path=$(pwd)

export AWS_ACCESS_KEY_ID=$(./spruce json terraform-yaml-external/state.yml | ./jq -r ".terraform_outputs.lets_encrypt_access_key_id_curr")
export AWS_SECRET_ACCESS_KEY=$(./spruce json terraform-yaml-external/state.yml | ./jq -r ".terraform_outputs.lets_encrypt_secret_access_key_curr")

certbot certonly \
  -n --agree-tos \
  --server "${ACME_SERVER:-https://acme-staging-v02.api.letsencrypt.org/directory}" \
  --dns-route53 \
  --config-dir "${config_path}" \
  --email "${EMAIL}" \
  --domain "${DOMAIN}"

out_path=$(ls -d -1 ${config_path}/live/*/)
cp ${out_path}/*.pem acme
