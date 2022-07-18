variable "elb_subnets" {
  type = list(string)
}

variable "listeners_per_tcp_lb" {
  default = 10
}

variable "stack_description" {}

variable "tags" {
  type = map(string)
}

variable "tcp_allow_cidrs_ipv4" {
  default = ["0.0.0.0/0"]
}

variable "tcp_allow_cidrs_ipv6" {
  default = ["::/0"]
}

variable "tcp_first_port" {
  type = number
}

variable "tcp_lb_count" {
  default = 1
}

variable "vpc_id" {}

