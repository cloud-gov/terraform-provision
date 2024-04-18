variable "sns_cg_platform_notifications_name" {
  type        = string
  description = "SNS Topic Name for platform notifications"
}

variable "sns_cg_platform_slack_notifications_name" {
  type        = string
  description = "SNS Topic Name for platform slack notification"
}

variable "sns_cg_platform_notifications_email" {
  type        = string
  description = "Email to receive platform notifications"
}

variable "sns_cg_platform_slack_notifications_email" {
  type        = string
  description = "Email to receive to platform slack notifications"
}
