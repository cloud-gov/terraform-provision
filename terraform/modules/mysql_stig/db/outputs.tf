output "mysqlstig_rds_host" {
  value = module.db.rds_host
}

output "mysqlstig_rds_port" {
  value = module.db.rds_port
}

output "mysqlstig_rds_url" {
  value = module.db.rds_url
}

output "mysqlstig_rds_name" {
  value = module.db.rds_name
}

output "mysqlstig_rds_username" {
  value = module.db.rds_username
}

output "mysqlstig_rds_password" {
  value     = module.db.rds_password
  sensitive = true
}
