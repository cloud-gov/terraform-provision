output "username" {
  value = var.username
}

output "access_key_id" {
  value = aws_iam_access_key.iam_access_key_v2.id
}

output "secret_access_key" {
  value = aws_iam_access_key.iam_access_key_v2.secret
}
