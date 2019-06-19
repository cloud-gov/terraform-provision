variable "stack_description" {}

variable "vpc_id" {}
variable "security_group" {}
variable "certificate_arn" {}
variable "public_subnet_az1" {}
variable "public_subnet_az2" {}
variable "hosts" {
  type = "list"
}
variable "log_bucket_name" {}
