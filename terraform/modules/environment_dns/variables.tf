variable "zone_id" {

}

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

variable "cf_lb_dns_name" {
  type        = string
  description = "DNS name of load balancer for CF"
}

variable "cf_apps_lb_dns_name" {
  type        = string
  description = "DNS name of load balancer for CF apps"
}

variable "cf_uaa_lb_dns_name" {
  type        = string
  description = "DNS name of load balancer for UAA connected to CF"
}

variable "main_lb_dns_name" {
  type        = string
  description = "DNS for load balancer handling non-CF traffic"
}

variable "diego_elb_dns_name" {
  type        = string
  description = "DNS name for load balancer handling Diego traffic"
}

variable "tcp_lb_dns_names" {
  type        = list(string)
  description = "DNS names for load balancers handling TCP traffic"
}

variable "log_alerts_ses_dkim_attribute_tokens" {
  type        = list(string)
  description = "Tokens to use for DKIM verification of SES identity handling log alerts"
}

variable "log_alerts_dmarc_email" {
  type        = string
  description = "Email address to which DMARC aggregate reports should be sent for log alert emails sent via SES."
}

variable "log_alerts_ses_aws_region" {
  type        = string
  description = "Name of AWS region where log alert SES resources are deployed"
}

variable "log_alerts_ses_mail_from_subdomain" {
  type        = string
  description = "Subdomain to use as MAIL FROM subdomain for log alerts SES identity"
  default     = "mail"
}
