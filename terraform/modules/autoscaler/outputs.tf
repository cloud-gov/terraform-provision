
output "cf_as_rds_url" {
  value = module.cf_as_database.rds_url
}

output "cf_as_rds_host" {
  value = module.cf_as_database.rds_host
}

output "cf_as_rds_port" {
  value = module.cf_as_database.rds_port
}

output "cf_as_rds_username" {
  value = module.cf_as_database.rds_username
}

output "cf_as_rds_password" {
  value     = module.cf_as_database.rds_password
  sensitive = true
}

output "cf_as_rds_engine" {
  value = module.cf_as_database.rds_engine
}
