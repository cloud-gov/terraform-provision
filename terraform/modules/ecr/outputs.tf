output "ecr_repository_url" {
  value = aws_ecr_repository.repository.repository_url
}

output "rds_name" {
  value = aws_db_instance.rds_database.name
}



