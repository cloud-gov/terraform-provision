resource "aws_iam_user" "ses_smtp_user" {
  for_each = toset(var.usernames)
  name     = "${var.resource_prefix}-${each.value}"
  path     = "/${var.resource_prefix}"
}

data "aws_iam_policy_document" "ses_smtp_send_mail_policy_doc" {
  statement {
    effect  = "Allow"
    actions = ["ses:SendRawEmail"]
    resources = [
      var.ses_email_identity_arn,
      var.ses_configuration_set_arn
    ]
  }
}

resource "aws_iam_user_policy" "ses_smtp_send_mail_policy" {
  for_each = toset(var.usernames)
  name     = "${var.resource_prefix}-ses-send-mail-policy"
  user     = aws_iam_user.ses_smtp_user[each.key].name
  policy   = data.aws_iam_policy_document.ses_smtp_send_mail_policy_doc.json
}

resource "aws_iam_access_key" "ses_smtp_credentials" {
  for_each = toset(var.usernames)
  user     = aws_iam_user.ses_smtp_user[each.key].name
}
