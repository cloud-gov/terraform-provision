variable "stack_description" {
}

variable "credhub_cidrs" {
  type    = list(string)
  default = ["10.0.36.0/24", "10.0.37.0/24"]
}

variable "credhub_availability_zones" {
  type    = list(string)
  default = ["us-gov-west-1a", "us-gov-west-1b"]
}

variable "rds_db_name" {
  default = "credhub"
}

variable "rds_parameter_group_name" {
  default = ""
}

variable "rds_parameter_group_family" {
  default = "postgres12"
}

variable "rds_db_size" {
  default = 200
}

variable "rds_db_iops" {
  default = 0
}

variable "rds_db_storage_type" {
  default = "gp2"
}

variable "rds_instance_type" {
  default = "db.m5.xlarge"
}

variable "rds_db_engine_version" {
  default = "12.11"
}

variable "rds_username" {
  default = "atc"
}

variable "rds_password" {
  sensitive = true
}

variable "rds_subnet_group" {
}

variable "rds_security_groups" {
  type = list(string)
}

variable "rds_multi_az" {
}

variable "rds_final_snapshot_identifier" {
}

variable "rds_allow_major_version_upgrade" {
}

variable "rds_apply_immediately" {
}

variable "route_table_ids" {
}

variable "vpc_id" {
}

variable "listener_arn" {
}

variable "hosts" {
  type = list(string)
}

