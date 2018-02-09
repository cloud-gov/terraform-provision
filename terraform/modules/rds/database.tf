/*
 * Variables required:
 *  stack_description
 *  rds_db_engine
 *  rds_db_engine_version
 *  rds_db_name
 *  rds_db_size
 *  rds_db_storage_type
 *  rds_instance_type
 *  rds_username
 *  rds_password
 *  rds_subnet_group
 *  rds_security_groups
 */

resource "aws_db_instance" "rds_database" {
  engine               = "${var.rds_db_engine}"
  engine_version       = "${var.rds_db_engine_version}"

  multi_az = true

  lifecycle {
    ignore_changes = ["identifier"]
    prevent_destroy = true
  }
  identifier = "${var.stack_description}-${element(split("-", uuid()),4)}"

  backup_retention_period = 30

  auto_minor_version_upgrade = true

  name = "${var.rds_db_name}"
  allocated_storage = "${var.rds_db_size}"
  storage_type = "${var.rds_db_storage_type}"
  iops = "${var.rds_db_iops}"
  instance_class = "${var.rds_instance_type}"

  username = "${var.rds_username}"
  password = "${var.rds_password}"

  storage_encrypted = true

  db_subnet_group_name = "${var.rds_subnet_group}"
  vpc_security_group_ids = ["${var.rds_security_groups}"]
  parameter_group_name = "${var.rds_db_engine == "postgres" ?
    "${join("", aws_db_parameter_group.parameter_group_postgres.*.id)}" :
    "${join("", aws_db_parameter_group.parameter_group_mysql.*.id)}"}"

  tags {
    Name = "${var.stack_description}"
  }
}
