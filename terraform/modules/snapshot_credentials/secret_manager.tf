resource "aws_secretsmanager_secret" "snapshot" {
  name        = "${var.resource_prefix}/credentials"
  description = "IAM snapshot credentials for ${var.resource_prefix}"
}

resource "aws_secretsmanager_secret_version" "snapshot" {
  secret_id = aws_secretsmanager_secret.snapshot.id

  secret_string = jsonencode({
    aws_access_key_id     = aws_iam_access_key.snapshot.id
    aws_secret_access_key = aws_iam_access_key.snapshot.secret
    iam_user              = aws_iam_user.snapshot.name
  })
}
