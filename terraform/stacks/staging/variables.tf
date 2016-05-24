variable "vpc_cidr" {
    default = "10.9.0.0/16"
}

variable "stack_description" {
    default = "staging"
}

variable "public_cidr_1" {
    default = "10.9.100.0/24"
}

variable "public_cidr_2" {
    default = "10.9.101.0/24"
}

variable "private_cidr_1" {
    default = "10.9.1.0/24"
}

variable "private_cidr_2" {
    default = "10.9.2.0/24"
}

variable "rds_private_cidr_1" {
    default = "10.9.20.0/24"
}

variable "rds_private_cidr_2" {
    default = "10.9.21.0/24"
}

variable "rds_password" {}

variable "peer_owner_id" {}

variable "target_vpc_id" {}

variable "target_vpc_cidr" {
    default = "10.99.0.0/16"
}

variable "target_az1_private_route_table" {}

variable "target_az2_private_route_table" {}
