variable "resource_prefix" {
  description = "Prefix used for naming the IAM user and Secrets Manager secret"
  type        = string
}

variable "bucket" {
  description = "ARN of the S3 bucket to grant snapshot permissions on"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
