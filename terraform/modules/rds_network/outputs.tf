output "rds_subnet_az1" {
  value = aws_subnet.az1_rds.id
}

output "rds_subnet_az3" {
  value = aws_subnet.az3_rds.id
}

output "rds_subnet_az2" {
  value = aws_subnet.az2_rds.id
}

output "rds_subnet_az4" {
  value = aws_subnet.az4_rds.id
}


output "rds_private_cidr_1" {
  value = aws_subnet.az1_rds.cidr_block
}

output "rds_private_cidr_3" {
  value = aws_subnet.az3_rds.cidr_block
}

output "rds_private_cidr_2" {
  value = aws_subnet.az2_rds.cidr_block
}

output "rds_private_cidr_4" {
  value = aws_subnet.az4_rds.cidr_block
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
