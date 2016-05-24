
variable "rds_password" {}

variable "concourse_prod_rds_password" {}
variable "concourse_prod_cidr" {
    default = "10.99.30.0/24"
}

variable "concourse_staging_rds_password" {}
variable "concourse_staging_cidr" {
    default = "10.99.31.0/24"
}