resource "aws_db_parameter_group" "parameter_group_postgres" {
  count = var.rds_db_engine == "postgres" ? 1 : 0
  name = var.rds_parameter_group_name != "" ? var.rds_parameter_group_name : replace(
    "${var.stack_description}-${var.rds_db_name}",
    "/[^a-zA-Z-]+/",
    "-",
  )

  family = var.rds_parameter_group_family

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  parameter {
    name  = "log_hostname"
    value = "0"
  }

  parameter {
    name  = "log_statement"
    value = "ddl"
  }

  parameter {
    name         = "rds.force_ssl"
    value        = 1
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "shared_preload_libraries"
    value        = var.rds_shared_preload_libraries
    apply_method = "pending-reboot"
  }

  #  dynamic "parameter" {
  #    for_each = var.rds_add_pgaudit_to_shared_preload_libraries ? [1] : []
  #    content {
  #      name         = "shared_preload_libraries"
  #      value        = var.rds_shared_preload_libraries
  #      apply_method = "pending-reboot"
  #    }
  #  }

  dynamic "parameter" {
    for_each = var.rds_add_pgaudit_log_parameter ? [1] : []
    content {
      name         = "pgaudit.log"
      value        = var.rds_pgaudit_log_values
      apply_method = "pending-reboot"
    }
  }

  dynamic "parameter" {
    for_each = var.rds_add_log_replication_commands ? [1] : []
    content {
      name         = "log_replication_commands"
      value        = 1
      apply_method = "pending-reboot"
    }
  }

  parameter {
    name  = "log_error_verbosity"
    value = "verbose"
  }

}

resource "aws_db_parameter_group" "parameter_group_mysql" {
  count = var.rds_db_engine == "mysql" ? 1 : 0
  name = var.rds_parameter_group_name != "" ? var.rds_parameter_group_name : replace(
    "${var.stack_description}-${var.rds_db_name}",
    "/[^a-zA-Z-]+/",
    "-",
  )

  family = var.rds_parameter_group_family
  parameter {
    name  = "general_log"
    value = 1
  }
  parameter {
    name  = "log_output"
    value = "FILE"
  }
}
