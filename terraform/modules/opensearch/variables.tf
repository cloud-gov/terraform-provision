variable "stack_description" {
}

variable "private_elb_subnets" {
  type = list(string)
}

variable "bosh_security_group" {
}

variable "listener_arn" {
}

variable "elb_log_bucket_name" {
}

variable "aws_partition" {

}
