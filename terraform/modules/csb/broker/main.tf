// Use the RDS module instead of brokering a database inside Cloud Foundry.
// Eventually the CSB itself will broker RDS, so this avoids a circular dependency.
module "db" {
  source = "../../rds"

  stack_description               = var.stack_description
  rds_instance_type               = var.rds_instance_type
  rds_db_size                     = var.rds_db_size
  rds_db_engine                   = var.rds_db_engine
  rds_db_engine_version           = var.rds_db_engine_version
  rds_db_name                     = var.rds_db_name
  rds_username                    = var.rds_username
  rds_password                    = var.rds_password
  rds_subnet_group                = var.rds_subnet_group
  rds_security_groups             = var.rds_security_groups
  rds_parameter_group_family      = var.rds_parameter_group_family
  rds_allow_major_version_upgrade = var.rds_allow_major_version_upgrade
  rds_apply_immediately           = var.rds_apply_immediately
}

resource "cloudfoundry_user_provided_service" "db" {
  name  = "csb-db"
  space = "cloud-gov/services"
  credentials = {
    "db_name"  = module.db.rds_name
    "host"     = module.db.rds_host
    "name"     = module.db.rds_name
    "password" = module.db.rds_password
    "port"     = module.db.rds_port
    "uri"      = module.db.rds_url
    "username" = module.db.rds_username
  }
}
