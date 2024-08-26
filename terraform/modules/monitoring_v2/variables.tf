variable "stack_description" {
}

variable "monitoring_cidrs" {
  type = list(string)
}

variable "monitoring_availability_zones" {
  type    = list(string)
  default = ["us-gov-west-1a", "us-gov-west-1a"]
}

variable "route_table_ids" {
}

variable "vpc_id" {
}

variable "vpc_cidr" {
  type = string
}

variable "listener_arn" {
}

variable "hosts" {
  type = list(string)
}

variable "doomsday_oidc_client" {
}

variable "doomsday_oidc_client_secret" {
}


variable "opslogin_hostname" {

}
