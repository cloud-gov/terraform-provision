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


data "aws_iam_policy_document" "platform_elasticache_policy" {
  statement {
    actions = [
      "elasticache:DescribeReplicationGroups",
      "elasticache:DescribeCacheClusters",
      "elasticache:DescribeEvents",
      "elasticache:DescribeUpdateActions",
    ]

    resources = [
      "arn:${var.aws_partition}:elasticache:${var.aws_default_region}:${var.account_id}:replicationgroup:${local.elasticache_prefix}-*"
    ]
  }
}

resource "aws_iam_policy" "platform_iam_policy" {
  name   = var.platform_policy_name
  policy = data.aws_iam_policy_document.platform_elasticache_policy.json
}

locals {
  elasticache_prefix = "db"
}
