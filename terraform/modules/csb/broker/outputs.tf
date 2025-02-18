output "rds_host" {
  value = module.db.rds_host
}

output "rds_port" {
  value = module.db.rds_port
}

output "rds_url" {
  value = module.db.rds_url
}

output "rds_name" {
  value = module.db.rds_name
}

output "rds_username" {
  value = module.db.rds_username
}

output "rds_password" {
  value     = module.db.rds_password
  sensitive = true
}
