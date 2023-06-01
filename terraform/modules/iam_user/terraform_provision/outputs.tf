output "terraform_provision_access_secret" {
  value = aws_iam_access_key.iam_access_key_v1.secret
}

output "terraform_provision_access_id" {
  value = aws_iam_access_key.iam_access_key_v1.id
}