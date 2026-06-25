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

variable "platform_logs_secrets_prefix" {
  type        = string
  description = "Prefix for AWS Secrets Manager platform logs secrets that should be readable"
}

variable "logs_snapshot_secrets_prefix" {
  type        = string
  description = "Prefix for AWS Secrets Manager logs snapshot secrets that should be readable"
}

variable "platform_snapshot_secrets_prefix" {
  type        = string
  description = "Prefix for AWS Secrets Manager platform snapshot secrets that should be readable"
}
