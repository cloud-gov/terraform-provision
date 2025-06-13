data "aws_iam_policy_document" "logs_opensearch_metric_ingestor_policy" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject"
    ]

    resources = [
      "arn:${var.aws_partition}:s3:::logs-opensearch-*/*"
    ]
  }
  statement {
    actions = [
      "s3:ListBucket"
    ]

    resources = [
      "arn:${var.aws_partition}:s3:::logs-opensearch-*"
    ]
  }
  statement {
    actions = [
      "s3:GetBucketTagging"
    ]

    resources = [
      "arn:aws-us-gov:s3:::cg-*",
      "arn:aws-us-gov:s3:::*-cg-*"
    ]
  }

  statement {
    actions = [
      "s3:ListAllMyBuckets"
    ]

    resources = [
      "arn:${var.aws_partition}:s3:::*",
    ]
  }

  statement {
    actions = [
      "es:ListTags"
    ]

    resources = [
      "arn:${var.aws_partition}:es:${var.aws_default_region}:${var.account_id}:domain/cg-*"
    ]
  }

  statement {
    actions = [
      "es:ListDomainNames",
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricStatistics"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "iam_policy" {
  name   = var.policy_name
  policy = data.aws_iam_policy_document.logs_opensearch_metric_ingestor_policy.json
}
