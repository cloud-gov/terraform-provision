resource "aws_db_parameter_group" "parameter_group_postgres" {
  count = "${var.rds_db_engine == "postgres" ? 1 : 0}"
  name = "${var.rds_parameter_group_name != "" ?
    var.rds_parameter_group_name :
    "${replace("${var.stack_description}-${var.rds_db_name}", "/[^a-zA-Z-]+/", "-")}"}"
  family = "${var.rds_parameter_group_family}"

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
    name = "rds.force_ssl"
    value = "${var.rds_force_ssl}"
    apply_method = "pending-reboot"
  }
}

resource "aws_db_parameter_group" "parameter_group_mysql" {
  count = "${var.rds_db_engine == "mysql" ? 1 : 0}"
  name = "${var.rds_parameter_group_name != "" ?
    var.rds_parameter_group_name :
    "${replace("${var.stack_description}-${var.rds_db_name}", "/[^a-zA-Z-]+/", "-")}"}"
  family = "${var.rds_parameter_group_family}"
  parameter {
    name = "general_log"
    value = 1
  }
  parameter {
    name = "log_output"
    value = "FILE"
  }
}
