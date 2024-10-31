output "primary_endpoint" {
  value = aws_elasticache_replication_group.replication_group.primary_endpoint_address
}

output "password" {
  value     = random_password.password.result
  sensitive = true
}
