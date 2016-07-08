
output "rds_url" {
    value = "${aws_db_instance.rds_database.endpoint}"
}

output "rds_host" {
    value = "${aws_db_instance.rds_database.address}"
}

output "rds_port" {
    value = "${aws_db_instance.rds_database.port}"
}

