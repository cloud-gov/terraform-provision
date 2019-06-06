variable "stack_description" {}
variable "vpc_id" {}
variable "private_elb_subnets" {type = "list"}
variable "bosh_security_group" {}
variable "listener_arn" {}
variable "hosts" {
  type = "list"
}
variable "log_bucket_name" {}
