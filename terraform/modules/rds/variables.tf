
variable "stack_description" {
  default = "tooling"
}

variable "rds_subnet_az1" {}

variable "rds_subnet_az2" {}

variable "vpc_id" {}

variable "rds_instance_type" {
    default = "db.t2.medium"
}

variable "rds_db_size" {
    default = 5
}

variable "rds_db_name" {
    default = "database"
}

variable "rds_db_engine" {
    default = "postgres"
}

variable "rds_db_engine_version" {
    default = "9.4"
}

variable "rds_username" {
    default = "postgres"
}

variable "rds_password" {}