data "aws_iam_policy_document" "logs_opensearch_policy" {
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
      "arn:${var.aws_partition}:secretsmanager:${var.region}:${var.account_id}:secret:${var.resource_prefix}*",
      "arn:${var.aws_partition}:secretsmanager:${var.region}:${var.account_id}:secret:${var.platform_logs_secrets_prefix}*",
      "arn:${var.aws_partition}:secretsmanager:${var.region}:${var.account_id}:secret:${var.logs_snapshot_secrets_prefix}*",
      "arn:${var.aws_partition}:secretsmanager:${var.region}:${var.account_id}:secret:${var.platform_snapshot_secrets_prefix}*"
    ]
  }
}

resource "aws_iam_policy" "iam_policy" {
  name   = var.policy_name
  policy = data.aws_iam_policy_document.logs_opensearch_policy.json
}
