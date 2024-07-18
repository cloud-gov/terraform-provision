module "rds_96" {
  source = "../rds"

  stack_description               = "credhub-${var.stack_description}"
  rds_db_name                     = var.rds_db_name
  rds_instance_type               = var.rds_instance_type
  rds_db_size                     = var.rds_db_size
  rds_db_storage_type             = var.rds_db_storage_type
  rds_db_iops                     = var.rds_db_iops
  rds_db_engine_version           = var.rds_db_engine_version
  rds_username                    = var.rds_username
  rds_password                    = var.rds_password
  rds_subnet_group                = var.rds_subnet_group
  rds_security_groups             = var.rds_security_groups
  rds_parameter_group_name        = var.rds_parameter_group_name
  rds_parameter_group_family      = var.rds_parameter_group_family
  rds_allow_major_version_upgrade = var.rds_allow_major_version_upgrade
  rds_apply_immediately           = var.rds_apply_immediately
  rds_multi_az                    = var.rds_multi_az
  rds_final_snapshot_identifier   = var.rds_final_snapshot_identifier
}
