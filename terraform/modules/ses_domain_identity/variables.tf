variable "email_identity_subdomain" {
  type        = string
  description = "Domain to use for SES email identity"
}

variable "environment_domain" {
  type        = string
  description = "Domain for the environment (e.g. dev, stage, prod)"
}

variable "mail_from_domain" {
  type        = string
  description = "Domain to use for MAIL FROM for the SES email identity"
  default     = "mail"
}

variable "stack_description" {
  type        = string
  description = "Name of the stack (e.g. development, staging, production)"
}
