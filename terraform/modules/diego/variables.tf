variable "stack_description" {
}

variable "az1" {
  default = "us-gov-west-1a"
}

variable "az2" {
  default = "us-gov-west-1b"
}

variable "vpc_id" {
}

variable "elb_subnets" {
  type = list(string)
}

variable "ingress_cidrs" {
  type    = list(string)
  default = ["0.0.0.0"]
}

variable "log_bucket_name" {
}

