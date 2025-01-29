output "csb_username" {
  value = aws_iam_user.iam_user.name
}

output "csb_access_key_id_prev" {
  value = ""
}

output "csb_secret_access_key_prev" {
  value     = ""
  sensitive = true
}

output "csb_access_key_id_curr" {
  value = aws_iam_access_key.iam_access_key.id
}

output "csb_secret_access_key_curr" {
  value     = aws_iam_access_key.iam_access_key.secret
  sensitive = true
}

output "concourse_csb_access_key_id_prev" {
  value = ""
}

output "concourse_csb_secret_access_key_prev" {
  value     = ""
  sensitive = true
}

output "concourse_csb_access_key_id_curr" {
  value = one(aws_iam_access_key.concourse_csb_access_key[*].id)
}

output "concourse_csb_secret_access_key_curr" {
  value     = one(aws_iam_access_key.concourse_csb_access_key[*].secret)
  sensitive = true
}
