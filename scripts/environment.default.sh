#
# Cloud.gov infrastructure initialization properties
#
# Set these through the CLI so we are not continuously re-prompted
#
# To use this file:
#  1. Copy this file (environment.default.sh) to environment.sh (ignored by Git)
#  2. Set everything that is currently blank, and feel free to modify the default values
#  3. Source these variables into your environment (source environment.sh)
#  4. Run Terraform as usual (this time without the prompts)
#
# Note: This file must be sourced into the bash environment prior to initiating
#       Terraform commands (if it is used)
#

#
# For Terraform remote state configuration
#
export TF_VAR_remote_state_bucket=""

#
# AWS Account ID of the person running this operation
#
export TF_VAR_account_id=`aws ec2 describe-security-groups --group-names "Default" | jq -r ".SecurityGroups[].OwnerId"`

#
# AWS credentials and default region
#
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""
export AWS_DEFAULT_REGION="us-gov-west-1"
export TF_VAR_az1="us-gov-west-1a"
export TF_VAR_az2="us-gov-west-1b"
export TF_VAR_aws_access_key_id="${AWS_ACCESS_KEY_ID}"
export TF_VAR_aws_secret_access_key="${AWS_SECRET_ACCESS_KEY}"
export TF_VAR_aws_default_region="${AWS_DEFAULT_REGION}"

#
# Default VPC
export TF_VAR_default_vpc_id=`aws ec2 describe-vpcs --filters Name=isDefault,Values=true  | jq -r ".Vpcs[0].VpcId"`
export TF_VAR_default_vpc_cidr=`aws ec2 describe-vpcs --filters Name=isDefault,Values=true  | jq -r ".Vpcs[0].CidrBlock"`
export TF_VAR_default_vpc_route_table=`aws ec2 describe-route-tables --filters Name=vpc-id,Values=${TF_VAR_default_vpc_id} | jq -r ".RouteTables[0].RouteTableId"`

#
# Concourse credentials bucket
export TF_VAR_credentials_bucket=""
export TF_VAR_concourse_password=""