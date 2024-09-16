variable "username" {
  type        = string
  description = "The username of the IAM user."
}

variable "repository_arn" {
  type        = string
  description = "The ARN of the repository in ECR from which the user will pull images."
}
