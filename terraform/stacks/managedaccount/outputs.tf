output "tf_role_arn" {
  value = aws_iam_role.tfrole.arn
}

output "cert_role_arn" {
  value = aws_iam_role.certuploadrole.arn
}
