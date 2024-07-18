output "rds_subnet_ids" {
  value = aws_subnet.subnet_rds[*].id
}

output "rds_private_cidrs" {
  value = aws_subnet.subnet_rds[*].cidr_block
}

output "rds_subnet_group" {
  value = aws_db_subnet_group.rds.id
}

output "rds_mysql_security_group" {
  value = aws_security_group.rds_mysql.id
}

output "rds_postgres_security_group" {
  value = aws_security_group.rds_postgres.id
}

output "rds_mssql_security_group" {
  value = aws_security_group.rds_mssql.id
}

output "rds_oracle_security_group" {
  value = aws_security_group.rds_oracle.id
}
