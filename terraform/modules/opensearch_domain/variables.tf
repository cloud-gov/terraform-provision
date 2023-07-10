variable "instance_type" {
  type    = string
  default = "t3.medium.search"
}
variable "engine" {
  type    = string
  default = "OpenSearch_2.5"
}
variable "domain_name" {
  type = string
}
variable "instance_count" {
  default = 2
  type    = number
}

variable "dedicated_master_count" {
  default = 3
  type    = number
}
variable "dedicated_master_type" {
  default = "t3.medium.search"
  type    = string
}
variable "dedicated_master_enabled" {
  default = true
  type    = bool
}
variable "internal_user_database_enabled" {
  default = true
  type    = bool
}

variable "master_user_name" {
  type = string
}

variable "master_user_password" {
  type = string
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to use"
}

variable "allow_incoming_traffic_security_group_ids" {
  type        = list(string)
  description = "Specifies AWS Security Group IDs that should be able to send incoming traffic to this domain"
}

variable "subnet_ids" {
  type        = list(string)
  description = "AWS Subnet IDs to use for Opensearch domain"
}
