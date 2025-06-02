output "rds_host" {
  value = module.db_stig.rds_host
}

output "rds_port" {
  value = module.db_stig.rds_port
}

output "rds_url" {
  value = module.db_stig.rds_url
}

output "rds_name" {
  value = module.db_stig.rds_name
}

output "rds_username" {
  value = module.db_stig.rds_username
}

output "rds_password" {
  value     = module.db_stig.rds_password
  sensitive = true
}
