variable "aws_access_key" {
}

variable "aws_secret_key" {
  sensitive = true
}

variable "aws_region" {
}


variable "cloudfront_zone_id" {
  default     = "Z33AYJ8TM3BH4J"
  description = "This is a hard coded value based on the region being used, not a sensitive values"
}

variable "remote_state_bucket" {
}

variable "remote_state_region" {
}

variable "tooling_stack_name" {
}

#variable "production_stack_name" {
#}
#
#variable "staging_stack_name" {
#}
#
#variable "development_stack_name" {
#}
