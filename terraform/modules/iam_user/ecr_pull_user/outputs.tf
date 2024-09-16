output "username" {
  value = var.username
}

output "access_key_id_prev" {
  value = ""
}

output "secret_access_key_prev" {
  value     = ""
  sensitive = true
}

output "access_key_id_curr" {
  value = aws_iam_access_key.iam_access_key_v3.id
}

output "secret_access_key_curr" {
  value     = aws_iam_access_key.iam_access_key_v3.secret
  sensitive = true
}
