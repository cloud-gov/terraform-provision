data "aws_iam_policy_document" "elasticache_broker_policy" {
  statement {
    actions = [
      "elasticache:DescribeReplicationGroups",
      "elasticache:CreateReplicationGroup",
      "elasticache:DeleteReplicationGroup",
      "elasticache:CreateCacheParameterGroup",
      "elasticache:ModifyCacheParameterGroup",
      "elasticache:DeleteCacheParameterGroup"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "iam_policy" {
  name   = var.policy_name
  policy = data.aws_iam_policy_document.elasticache_broker_policy.json
}
