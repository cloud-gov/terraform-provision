output "username" {
  value = aws_iam_user.csb.name
}

output "access_key_id_prev" {
  value = aws_iam_access_key.csb.id
}

output "secret_access_key_prev" {
  value     = aws_iam_access_key.csb.secret
  sensitive = true
}

output "access_key_id_curr" {
  value = aws_iam_access_key.csb_v2.id
}

output "secret_access_key_curr" {
  value     = aws_iam_access_key.csb_v2.secret
  sensitive = true
}
