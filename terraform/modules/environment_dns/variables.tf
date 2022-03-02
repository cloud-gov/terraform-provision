
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

variable "admin_lb_dns_name" {

}

variable "cf_apps_lb_dns_name" {

}

variable "cf_lb_dns_name" {

}

variable "main_lb_dns_name" {

}

variable "diego_elb_dns_name" {

}

variable "cf_uaa_lb_dns_name" {

}

variable "tcp_lb_dns_names" {
  
}