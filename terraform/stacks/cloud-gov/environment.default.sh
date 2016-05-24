#
# Cloud.gov infrastructure initialization properties
#
# Set these through the CLI so we are not continuously re-prompted
#
# To use this file:
#  1. Copy this file (environment.default.sh) to environment.sh (ignored by Git)
#  2. Set your AWS account information and other configurations
#  3. Source these variables into your environment (source environment.sh)
#  4. Run Terraform as usual (this time without the prompts)
#
# Note: This file must be sourced into the bash environment prior to initiating
#       Terraform commands (if it is used)
#

#
# AWS Account ID of the person running this operation
#
export TF_VAR_account_id=""

#
# AWS credentials and default region
#
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""
export AWS_DEFAULT_REGION="us-gov-west-1"

#
# Tooling VPC settings
#
export TF_VAR_tooling_rds_password=""
export TF_VAR_concourse_prod_rds_password=""
export TF_VAR_concourse_staging_rds_password=""

#
# Production VPC settings
#
export TF_VAR_prod_rds_password=""

#
# Staging VPC settings
#
export TF_VAR_staging_rds_password=""