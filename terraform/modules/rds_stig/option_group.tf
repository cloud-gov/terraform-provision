resource "aws_db_option_group" "option_group_mysql" {
  count = var.rds_db_engine == "mysql" ? 1 : 0
  name = var.rds_option_group_name != "" ? var.rds_option_group_name : replace(
    "${var.stack_description}-${var.rds_db_name}",
    "/[^a-zA-Z-]+/",
    "-",
  )

  option_group_description = "MySQL STIG Option Group"
  engine_name              = var.rds_db_engine
  major_engine_version     = var.rds_db_engine_version

  option {
    option_name = "MARIADB_AUDIT_PLUGIN"
  }
}
