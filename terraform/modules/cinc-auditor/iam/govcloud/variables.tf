variable "stack_description" {
  type        = string
  description = "Like development, staging, or production."
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
