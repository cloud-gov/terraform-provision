variable "email_identity_subdomain" {
  type        = string
  description = "Domain to use for SES email identity"
}

variable "environment_domain" {
  type        = string
  description = "Domain for the environment (e.g. dev, stage, prod)"
}

variable "mail_from_subdomain" {
  type        = string
  description = "Subdomain to set as the mail-from value."
  default     = "no-reply"
}

variable "stack_description" {
  type        = string
  description = "Name of the stack (e.g. development, staging, production)"
}
