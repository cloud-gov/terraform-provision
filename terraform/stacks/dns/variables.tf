# Most stacks do not pass credentials this way. For an explanation of why
# access and state are managed differently in the DNS stack compared to the
# other stacks, see README.md, "DNS Stack" in the root of the repo.
variable "aws_access_key" {
}

variable "aws_secret_key" {
  sensitive = true
}

variable "aws_region" {
}

variable "cloudfront_zone_id" {
  default = "Z33AYJ8TM3BH4J"
}

variable "remote_state_bucket" {
}

variable "remote_state_region" {
}

variable "tooling_stack_name" {
}

variable "production_stack_name" {
}

variable "staging_stack_name" {
}

variable "development_stack_name" {
}

variable "log_alerts_dmarc_email" {
  type        = string
  description = "Email address to which DMARC aggregate reports should be sent for log alert emails sent via SES."
}

variable "log_alerts_ses_aws_region" {
  type        = string
  description = "Name of AWS region where log alert SES resources are deployed"
}
