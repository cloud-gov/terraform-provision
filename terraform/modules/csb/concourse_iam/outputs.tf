output "access_key_id_prev" {
  value = ""
}

output "secret_access_key_prev" {
  value     = ""
  sensitive = true
}

output "access_key_id_curr" {
  value = aws_iam_access_key.concourse_csb.id
}

output "secret_access_key_curr" {
  value     = aws_iam_access_key.concourse_csb.secret
  sensitive = true
}
