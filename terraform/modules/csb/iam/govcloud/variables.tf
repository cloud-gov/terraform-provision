variable "stack_description" {
  type        = string
  description = "Like development, staging, or production."
}

variable "sns_platform_notification_topic_arn" {
  type        = string
  description = "Required to give the Concourse IAM user permission to subscribe the CSB Helper to the topic."
}

variable "ecr_remote_state_bucket" {
  type        = string
  description = "Required to resolve the docker image repository ARNs."
}

variable "ecr_remote_state_region" {
  type        = string
  description = "Required to resolve the docker image repository ARNs."
}

variable "ecr_stack_name" {
  type        = string
  description = "The name of the stack that configures ECR. Required to resolve the docker image repository ARNs."
}
