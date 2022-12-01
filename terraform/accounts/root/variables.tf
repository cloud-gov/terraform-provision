variable "aws_access_key" {
  type = string
  description = "AWS access key ID for deploying to target account"
}

variable "aws_secret_key" {
  type = string
  description = "AWS secret key for deploying to target account"
}

variable "aws_region" {
  type = string
  description = "AWS region to use in target account"
  default = "us-gov-west-1"
}

variable "config_delegated_administrator_account_id" {
  type = string
  description = "AWS account ID to designate as delegated administrator for AWS Config in AWS Organization"
}
