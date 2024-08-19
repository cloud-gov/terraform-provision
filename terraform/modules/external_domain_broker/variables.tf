variable "account_id" {
  type        = string
  description = "AWS account ID where the resources are deployed"
}

variable "stack_description" {
  type        = string
  description = "Description of environment where resources are deployed (e.g. production)"
}

variable "aws_partition" {
  type        = string
  description = "AWS partition where the resources are deployed"
}

variable "aws_region" {
  type        = string
  description = "AWS region where the resources are deployed"
}

variable "aggregate_key_type" {
  type        = string
  description = "What should be used to aggregate requests and enforce rate limiting"
  default     = "IP"
}

variable "evaluation_window_sec" {
  type        = number
  description = "Time period (in seconds) requests should be aggregated before rate-limiting"
  default     = 60
}

variable "waf_rate_limit_challenge_threshold" {
  type        = number
  description = "Number of requests at which traffic by the aggregate key is rate-limited with a CHALLENGE response"
}

variable "waf_rate_limit_count_threshold" {
  type        = number
  description = "Number of requests at which traffic by the aggregate key is counted. This threshold is useful to update if you suspect a lower rate-limit threshold might be effective and want to evaluate it without disrupting traffic."
}

variable "scope" {
  type        = string
  description = "Specifies whether this is for an AWS CloudFront distribution or for a regional application. Valid values are CLOUDFRONT or REGIONAL."
}
