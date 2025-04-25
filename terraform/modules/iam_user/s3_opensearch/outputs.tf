output "username" {
  value = var.username
}

output "access_key_id_prev" {
  value = ""
}

output "secret_access_key_prev" {
  value = ""
}

output "access_key_id_curr" {
  value = aws_iam_access_key.logs_opensearch_s3_user_access_key_id_curr.id
}

output "secret_access_key_curr" {
  value = aws_iam_access_key.logs_opensearch_s3_user_access_key_id_curr.secret
  sensitive = true
}
