resource "aws_db_option_group" "option_group_mysql" {
  count = var.rds_db_engine == "mysql" ? 1 : 0
  name  = var.rds_option_group_name != "" ? var.rds_option_group_name : local.rds_group_name

  option_group_description = "MySQL STIG Option Group"
  engine_name              = var.rds_db_engine
  major_engine_version     = var.rds_db_engine_version

  option {
    option_name = "MARIADB_AUDIT_PLUGIN"
  }

  # An engine upgrade changes the name, which forces replacement. Create the
  # new group before destroying the old one so the DB instance always has a
  # group to point at; AWS refuses to delete a group that is still in use.
  lifecycle {
    create_before_destroy = true
  }
}
