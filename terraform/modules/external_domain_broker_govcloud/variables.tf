variable "account_id" {
}

variable "stack_description" {
}

variable "aws_partition" {
  type        = string
  description = "AWS partition where the resources are deployed"
}

variable "aws_region" {
  type        = string
  description = "AWS region where the resources are deployed"
}

variable "waf_log_group_arn" {
  type        = string
  description = "ARN of CloudWatch log group for WAF logs"
}
