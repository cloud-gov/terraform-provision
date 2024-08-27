variable "stack_description" {
}


variable "external_domain_broker_hosted_zone" {
}

variable "cdn_broker_hosted_zone" {
}


variable "lets_encrypt_hosted_zone" {
}

variable "external_domain_waf_rate_limit_challenge_threshold" {
  type        = number
  description = "Number of requests at which traffic by the aggregate key is rate-limited with a CHALLENGE response"
}

variable "external_domain_waf_rate_limit_count_threshold" {
  type        = number
  description = "Number of requests at which traffic by the aggregate key is counted. This threshold is useful to update if you suspect a lower rate-limit threshold might be effective and want to evaluate it without disrupting traffic."
}

variable "main_stack_terraform_state_bucket" {
  type        = string
  description = "S3 Bucket name containing Terraform state for main stack"
}

variable "main_stack_name" {
  type        = string
  description = "Name of Terraform deployment for main stack"
}

variable "main_stack_region" {
  type        = string
  description = "Name of AWS region containing Terraform state for main stack"
}
