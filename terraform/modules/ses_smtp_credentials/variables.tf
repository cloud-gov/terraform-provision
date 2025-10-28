variable "resource_prefix" {
  type        = string
  description = "Prefix to use for resource names"
}

variable "smtp_users" {
  type        = list(string)
  description = "List of user identifiers needing SES SMTP credentials"
  default     = []
}
