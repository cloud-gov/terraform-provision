#!/bin/bash

set -eu

AWS_ACCESS_KEY_ID=$(spruce json terraform-yaml-external/state.yml | jq -r ".terraform_outputs.iam_dev_user_access_key_id_curr")
AWS_SECRET_ACCESS_KEY=$(spruce json terraform-yaml-external/state.yml | jq -r ".terraform_outputs.iam_dev_user_secret_access_key_curr")

credhub set -t value -n /roberts/awesome/adventure/dev_access_key -v $AWS_SECRET_ACCESS_KEY
credhub set -t value -n /roberts/awesome/adventure/dev_access_key_id -v $AWS_ACCESS_KEY_ID