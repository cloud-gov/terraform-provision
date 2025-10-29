resource "aws_secretsmanager_secret" "ses_smtp_creds_secret" {
  for_each = toset(var.usernames)
  name     = "${var.resource_prefix}-${each.value}-ses-smtp-creds"
}

resource "aws_secretsmanager_secret_version" "ses_smtp_creds_secret_version" {
  for_each  = toset(var.usernames)
  secret_id = aws_secretsmanager_secret.ses_smtp_creds_secret[each.key].id
  secret_string = jsonencode({
    "smtp_username" = aws_iam_access_key.ses_smtp_credentials[each.key].id
    "smtp_password" = aws_iam_access_key.ses_smtp_credentials[each.key].ses_smtp_password_v4
  })
}
