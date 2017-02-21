output "rds_identifier" {
  value = "${aws_db_instance.rds_database.identifier}"
}

output "rds_name" {
  value = "${aws_db_instance.rds_database.name}"
}

output "rds_url" {
  value = "${aws_db_instance.rds_database.endpoint}"
}

output "rds_host" {
  value = "${aws_db_instance.rds_database.address}"
}

output "rds_port" {
  value = "${aws_db_instance.rds_database.port}"
}

output "rds_username" {
  value = "${aws_db_instance.rds_database.username}"
}

output "rds_password" {
  value = "${aws_db_instance.rds_database.password}"
}

output "rds_engine" {
  value = "${aws_db_instance.rds_database.engine}"
}
