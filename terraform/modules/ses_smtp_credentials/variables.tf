variable "resource_prefix" {
  type        = string
  description = "Prefix to use for resource names"
}

variable "usernames" {
  type        = list(string)
  description = "List of users needing SES SMTP credentials"
  default     = []
}

variable "ses_email_identity_arn" {
  type        = string
  description = "ARN of SES email identity that will be used to send emails"
}

variable "ses_configuration_set_arn" {
  type        = string
  description = "ARN of SES configuration set for the email identity"
}
