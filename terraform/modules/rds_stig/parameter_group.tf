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

  # SV-235137
  parameter {
    name  = "validate_password_length"
    value = 24
  }

  parameter {
    name  = "validate_password_policy"
    value = "STRONG"
  }

  parameter {
    name  = "password_history"
    value = 5
  }

  parameter {
    name  = "password_reuse_interval"
    value = 365
  }

  parameter {
    name  = "default_password_lifetime"
    value = 180
  }

  # This can apply immediately
  parameter {
    name  = "require_secure_transport"
    value = 1
  }

  # The AWS max_connections value is nominally, {DBInstanceClassMemory/12582880}, 
  # but can be as low a 80% of that value, so we use a denominator 33% higher,
  # 16777173, to provide enough headroom for some connections to remain free
  parameter {
    name         = "max_user_connections"
    value        = "{DBInstanceClassMemory/16777173}"
    apply_method = "pending-reboot"
  }
}
