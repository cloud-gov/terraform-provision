variable "instance_type" {
  default = "t3.medium.search"
}
variable "engine" {
  type    = string
  default = "Opensearch_2.5"
}
variable "domain_name" {

}
variable "instance_count" {
  default = 1
}

variable "dedicated_master_count" {
  default = 1

}
variable "dedicated_master_type" {
  default = "t3.medium.search"
}
variable "dedicated_master_enabled" {
  default = true
}
variable "internal_user_database_enabled" {
  default = true
}

variable "master_user_name" {

}
variable "master_user_password" {

}
variable "private_elb_subnets" {
  type = list(string)
}
