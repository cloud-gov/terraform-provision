// CSB
output "csb_access_key_id_prev" {
  value = ""
}

output "csb_secret_access_key_prev" {
  value     = ""
  sensitive = true
}

output "csb_access_key_id_curr" {
  value = aws_iam_access_key.csb.id
}

output "csb_secret_access_key_curr" {
  value     = aws_iam_access_key.csb.secret
  sensitive = true
}

// Concourse
output "concourse_access_key_id_prev" {
  value = ""
}

output "concourse_secret_access_key_prev" {
  value     = ""
  sensitive = true
}

output "concourse_access_key_id_curr" {
  value = aws_iam_access_key.concourse.id
}

output "concourse_secret_access_key_curr" {
  value     = aws_iam_access_key.concourse.secret
  sensitive = true
}

// ECR
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
