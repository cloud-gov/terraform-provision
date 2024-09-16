output "ecr_user_username" {
  value = module.ecr_user.username
}

output "ecr_user_access_key_id_curr" {
  value = module.ecr_user.access_key_id_curr
}

output "ecr_user_secret_access_key_curr" {
  value     = module.ecr_user.secret_access_key_curr
  sensitive = true
}

output "ecr_user_access_key_id_prev" {
  value = module.ecr_user.access_key_id_prev
}

output "ecr_user_secret_access_key_prev" {
  value     = module.ecr_user.secret_access_key_prev
  sensitive = true
}

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
