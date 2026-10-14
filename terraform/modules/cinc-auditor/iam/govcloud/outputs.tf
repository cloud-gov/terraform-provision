// ECR
output "ecr_access_key_id_curr" {
  value = module.ecr_user.access_key_id_curr
}

output "ecr_secret_access_key_curr" {
  value     = module.ecr_user.secret_access_key_curr
  sensitive = true
}

output "ecr_access_key_id_prev" {
  value = module.ecr_user.access_key_id_prev
}

output "ecr_secret_access_key_prev" {
  value     = module.ecr_user.secret_access_key_prev
  sensitive = true
}
