variable "stack_description" {
}

variable "health_check_env" {
  type    = string
  default = "staging"
}

variable "terraform_state_bucket" {
  type        = string
  description = "The name of the bucket in which terraform state for this stack is stored."
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

variable "sns_cg_platform_notifications_email" {
  type        = string
  description = "Email to receive platform notifications"

}

variable "sns_cg_platform_slack_notifications_email" {
  type        = string
  description = "Email to receive platform slack notifications"
}
