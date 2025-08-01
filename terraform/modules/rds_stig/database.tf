resource "aws_db_instance" "rds_database" {
  engine         = var.rds_db_engine
  engine_version = var.rds_db_engine_version

  multi_az = var.rds_multi_az

  lifecycle {
    ignore_changes  = [identifier]
    prevent_destroy = false
  }

  identifier = "${var.stack_description}-${element(split("-", uuid()), 4)}"

  final_snapshot_identifier = var.rds_final_snapshot_identifier == "" ? "final-snapshot-${var.rds_db_name}-${var.stack_description}" : var.rds_final_snapshot_identifier

  backup_retention_period = 35

  auto_minor_version_upgrade = true

  db_name           = var.rds_db_name
  allocated_storage = var.rds_db_size
  storage_type      = var.rds_db_storage_type
  iops              = var.rds_db_iops
  instance_class    = var.rds_instance_type

  username = var.rds_username
  password = var.rds_password

  storage_encrypted = true

  db_subnet_group_name   = var.rds_subnet_group
  vpc_security_group_ids = var.rds_security_groups

  performance_insights_enabled = var.performance_insights_enabled

  parameter_group_name = var.rds_db_engine == "postgres" ? aws_db_parameter_group.parameter_group_postgres[0].id : aws_db_parameter_group.parameter_group_mysql[0].id
  option_group_name    = aws_db_option_group.option_group_mysql[0].id

  allow_major_version_upgrade = var.rds_allow_major_version_upgrade
  apply_immediately           = var.rds_apply_immediately

  tags = {
    Name = var.stack_description
  }
}
