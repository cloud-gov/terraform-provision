# Most stacks do not pass credentials this way. For an explanation of why
# access and state are managed differently in the cloudfront stack compared
# to the other stacks, see README.md, "DNS and CloudFront Stacks" in the root
# of the repo.
variable "aws_access_key" {
}

variable "aws_secret_key" {
  sensitive = true
}

variable "aws_region" {
}

variable "stack_description" {
  type = string
}

variable "remote_state_bucket" {
  type = string
}

variable "remote_state_region" {
  type = string
}
