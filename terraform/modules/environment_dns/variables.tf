
variable "app_subdomain" {

}
variable "admin_subdomain" {

}

variable "domain" {

}

variable "stack_name" {

}

variable "alb_zone_id" {
  default = "Z33AYJ8TM3BH4J" # this is for us-gov-west-1. See others here: https://docs.aws.amazon.com/general/latest/gr/elb.html
}

variable "nlb_zone_id" {
  default = "ZMG1MZ2THAWF1" # this is for us-gov-west-1. See others here: https://docs.aws.amazon.com/general/latest/gr/elb.html
}
variable "remote_state_bucket" {

}
variable "remote_state_region" {

}