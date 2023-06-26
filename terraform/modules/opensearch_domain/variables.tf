variable "instance_type" {
  type = string
  default = "t3.medium.search"
}
variable "engine" {
  type    = string
  default = "Opensearch_2.5"
}
variable "domain_name" {
 type = string
}
variable "instance_count" {
  default = 1
  type = number
}

variable "dedicated_master_count" {
  default = 1
  type = number
}
variable "dedicated_master_type" {
  default = "t3.medium.search"
  type = string
}
variable "dedicated_master_enabled" {
  default = true
  type = bool
}
variable "internal_user_database_enabled" {
  default = true
  type = bool
}

variable "master_user_name" {
 type = string
}
variable "master_user_password" {
 type = string
}
variable "private_elb_subnets" {
  type = list(string)
}
