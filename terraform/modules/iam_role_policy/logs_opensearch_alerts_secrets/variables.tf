variable "policy_name" {
}

variable "account_id" {
}

variable "aws_partition" {
}

variable "region" {
}

variable "resource_prefix" {
  type        = string
  description = "Prefix for AWS Secrets Manager secrets that should be readable"
}
