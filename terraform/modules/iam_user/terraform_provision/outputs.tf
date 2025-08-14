output "terraform_provision_access_secret_prev" {
  value = aws_iam_access_key.iam_access_key_v1.secret
}

output "terraform_provision_access_id_prev" {
  value = aws_iam_access_key.iam_access_key_v1.id
}

output "terraform_provision_access_secret_curr" {
  value = aws_iam_access_key.iam_access_key_v2.secret
}

output "terraform_provision_access_id_curr" {
  value = aws_iam_access_key.iam_access_key_v2.id
}
