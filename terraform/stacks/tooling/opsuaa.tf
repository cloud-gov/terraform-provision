variable "opsuaa_rds_password" {
  sensitive = true
}

module "opsuaa_db" {
  source = "../../modules/rds"

  stack_description               = var.stack_description
  rds_instance_type               = "db.t3.medium"
  rds_db_name                     = "opsuaa"
  rds_username                    = "opsuaa"
  rds_password                    = var.opsuaa_rds_password
  rds_subnet_group                = module.stack.rds_subnet_group
  rds_security_groups             = [module.stack.rds_postgres_security_group]
  rds_db_engine_version           = var.rds_db_engine_version
  rds_parameter_group_family      = var.rds_parameter_group_family
  rds_allow_major_version_upgrade = var.rds_allow_major_version_upgrade
  rds_apply_immediately           = var.rds_apply_immediately
}

output "opsuaa_rds_url" {
  value = module.opsuaa_db.rds_url
}

output "opsuaa_rds_host" {
  value = module.opsuaa_db.rds_host
}

output "opsuaa_rds_port" {
  value = module.opsuaa_db.rds_port
}

output "opsuaa_rds_username" {
  value = module.opsuaa_db.rds_username
}

output "opsuaa_rds_password" {
  value     = module.opsuaa_db.rds_password
  sensitive = true
}

output "opsuaa_rds_engine" {
  value = module.opsuaa_db.rds_engine
}

