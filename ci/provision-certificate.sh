#!/bin/bash

set -eu

curl -L -o jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
chmod +x ./jq

pip install certbot==2.6.0 
pip install certbot-dns-route53==2.6.0

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
  --domain "${DOMAIN}" \
  --rsa-key-size 2048 \
  --key-type rsa 

out_path=$(ls -d -1 ${config_path}/live/*/)
cp ${out_path}/*.pem acme

# Before provision exit - check that certificate and key are RSA based and 2048 bit length - if not error out task

CERT_CHECK=$(cat acme/cert.pem | openssl x509 -text -noout | grep "Public-Key")
KEY_CHECK=$(cat acme/privkey.pem | openssl rsa -text -noout | grep "Private-Key")

if [[ "$CERT_CHECK" == *"2048 bit"* ]]; then
    echo  "Certificate is 2048 bit and good"
    else
    echo "Certificate failed 2048 bit check and is bad/corrupt"
    exit 1
fi

if [[ "$KEY_CHECK" == *"RSA Private"* ]]; then
    echo  "Key is RSA based and good"
    else
    echo "Key is NOT RSA based and is bad/corrupt"
    exit 1
fi
