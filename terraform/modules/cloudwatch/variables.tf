variable "stack_description" {

}

variable "cg_platform_notifications_arn" {
  type        = string
  description = "ARN for the platform-notifications SNS Topic"

}

variable "cg_platform_slack_notifications_arn" {
  type        = string
  description = "ARN for the platform-slack-notifications SNS Topic"
}

variable "load_balancer_dns" {

}

variable "cloudwatch_lambda_function_name" {

}
variable "metric_lambda_function_name" {

}
variable "aws_partition" {

}
