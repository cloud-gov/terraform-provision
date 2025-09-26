variable "name_prefix" {
  description = "prefix for naming of resources"
  type        = string
  default     = "opensearch-metric-stream"
}

variable "account_id" {
  sensitive = true
}

variable "aws_partition" {
  type        = string
  description = "AWS partition where the resources are deployed"
}

variable "aws_region" {
  type        = string
  description = "AWS region where the resources are deployed"
}

variable "environments" {
  description = "list of environments to create"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags for firehose resources"
  type        = map(string)
  default     = {}
}

variable "firehose_buffer_size" {
  description = "Firehose buffer size in MB"
  type        = number
  default     = 5
}

variable "firehose_buffer_interval" {
  description = "Firehouse buffer interval in seconds"
  type        = number
  default     = 60
}

