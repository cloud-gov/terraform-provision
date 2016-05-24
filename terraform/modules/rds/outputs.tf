
output "rds_url" {
    value = "${aws_db_instance.rds_database.endpoint}"
}