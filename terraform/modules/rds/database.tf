/*
 * Variables required:
 *  stack_description
 *  rds_db_engine
 *  rds_db_engine_version
 *  rds_db_name
 *  rds_db_size
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
  }
  identifier = "${var.stack_description}-${element(split("-", uuid()),4)}"

  backup_retention_period = 30

  auto_minor_version_upgrade = true
  auto_minor_version_upgrade = false

  name = "${var.rds_db_name}"
  allocated_storage = "${var.rds_db_size}"
  instance_class = "${var.rds_instance_type}"

  username = "${var.rds_username}"
  password = "${var.rds_password}"

  storage_encrypted = "${var.rds_encrypted}"

  db_subnet_group_name = "${var.rds_subnet_group}"
  vpc_security_group_ids = ["${split(",", var.rds_security_groups)}"]

  tags = {
    Name = "${var.stack_description}"
  }
}