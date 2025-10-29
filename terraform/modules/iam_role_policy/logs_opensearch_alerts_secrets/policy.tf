data "aws_iam_policy_document" "log_alerts_secrets_reader_policy" {
  statement {
    actions = [
      "secretsmanager:ListSecrets",
    ]

    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]

    resources = [
      "arn:${var.aws_partition}:secretsmanager:${var.region}:${var.account_id}:secret:${var.resource_prefix}*"
    ]
  }
}

resource "aws_iam_policy" "iam_policy" {
  name   = var.policy_name
  policy = data.aws_iam_policy_document.log_alerts_secrets_reader_policy.json
}
