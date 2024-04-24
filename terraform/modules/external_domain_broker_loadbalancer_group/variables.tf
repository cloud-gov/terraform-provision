variable "stack_description" {

}

variable "domains_lbgroup_count" {
  default = 2
}

variable "elb_bucket_name" {
}

variable "subnets" {

}

variable "security_groups" {

}

variable "logstash_hosts" {

}

variable "vpc_id" {

}

variable "waf_arn" {

}

variable "wildcard_arn" {

}

variable "loadbalancer_forward_original_weight" {
  type        = number
  description = "Weight of traffic to send to original target groups"
  default     = 100
}

variable "loadbalancer_forward_new_weight" {
  type        = number
  description = "Weight of traffic to send to original target groups"
  default     = 0
}
