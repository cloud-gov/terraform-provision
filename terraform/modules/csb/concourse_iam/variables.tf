variable "stack_description" {
  type        = string
  description = "Like development, staging, or production."
}

variable "sns_platform_notification_topic_arn" {
  type = string
}
