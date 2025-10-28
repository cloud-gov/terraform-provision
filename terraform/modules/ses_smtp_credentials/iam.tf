resource "aws_iam_user" "ses_smtp_user" {
  for_each = toset(var.smtp_users)
  name     = var.resource_prefix
}
