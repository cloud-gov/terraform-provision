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
 */

resource "aws_db_instance" "rds_database" {
  engine               = "${var.rds_db_engine}"
  engine_version       = "${var.rds_db_engine_version}"

  multi_az = true

  backup_retention_period = 30

  auto_minor_version_upgrade = true
  auto_minor_version_upgrade = false

  name = "${var.rds_db_name}"
  allocated_storage = "${var.rds_db_size}"
  instance_class = "${var.rds_instance_type}"

  username = "${var.rds_username}"
  password = "${var.rds_password}"

  db_subnet_group_name = "${aws_db_subnet_group.rds.id}"
  vpc_security_group_ids = ["${aws_security_group.rds_postgres.id}", "${aws_security_group.rds_mysql.id}"]

  tags = {
    Name = "${var.stack_description}"
  }
}