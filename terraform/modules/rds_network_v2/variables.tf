variable "stack_description" {
}

variable "availability_zones" {
  type = list(string)
  default = ["us-gov-west-1a","us-gov-west-1b"]
}

variable "rds_private_cidrs" {
  type = list(string)
}

variable "route_table_ids" {
}

variable "vpc_id" {
}

variable "security_groups" {
  type = list(string)
}

variable "security_groups_count" {
}

variable "allowed_cidrs" {
  type = list(string)
}
