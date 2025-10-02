resource "aws_db_instance" "rds_database" {
  engine         = var.rds_db_engine
  engine_version = var.rds_db_engine_version

  multi_az = var.rds_multi_az

  lifecycle {
    ignore_changes  = [identifier]
    prevent_destroy = true
  }

  identifier = "${var.stack_description}-${element(split("-", uuid()), 4)}"

  final_snapshot_identifier = var.rds_final_snapshot_identifier == "" ? "final-snapshot-${var.rds_db_name}-${var.stack_description}" : var.rds_final_snapshot_identifier

  backup_retention_period = 35

  auto_minor_version_upgrade = true

  db_name        = var.rds_db_name
  instance_class = var.rds_instance_type

  # Configure Storage
  allocated_storage     = var.rds_db_size
  max_allocated_storage = var.rds_db_max_size
  storage_type          = var.rds_db_storage_type
  storage_encrypted     = true
  iops                  = var.rds_db_iops

  username = var.rds_username
  password = var.rds_password

  db_subnet_group_name   = var.rds_subnet_group
  vpc_security_group_ids = var.rds_security_groups

  performance_insights_enabled = var.performance_insights_enabled

  parameter_group_name = var.rds_db_engine == "postgres" ? join("", aws_db_parameter_group.parameter_group_postgres.*.id) : join("", aws_db_parameter_group.parameter_group_mysql.*.id)

  allow_major_version_upgrade = var.rds_allow_major_version_upgrade
  apply_immediately           = var.rds_apply_immediately

  tags = {
    Name = var.stack_description
  }
}
