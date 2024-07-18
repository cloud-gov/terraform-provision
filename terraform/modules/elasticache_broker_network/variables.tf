variable "stack_description" {
}

variable "az1" {
  default = "us-gov-west-1a"
}

variable "az2" {
  default = "us-gov-west-1b"
}

variable "elasticache_private_cidr_1" {
}

variable "elasticache_private_cidr_2" {
}

variable "az1_route_table" {
}

variable "az2_route_table" {
}

variable "vpc_id" {
}

variable "security_groups" {
  type = list(string)
}

variable "elb_subnets" {
  type = list(string)
}

variable "elb_security_groups" {
  type = list(string)
}

variable "log_bucket_name" {
}
