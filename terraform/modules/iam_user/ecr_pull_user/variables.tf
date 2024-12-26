variable "username" {
  type        = string
  description = "The username of the IAM user."
}

variable "repository_arns" {
  type        = list(string)
  description = "The ARNs of the repositories in ECR that the user will be permitted to pull from."
}
