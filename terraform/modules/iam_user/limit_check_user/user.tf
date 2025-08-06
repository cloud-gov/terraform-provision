data "aws_iam_policy_document" "limit_check_user_policy" {
  statement {
    actions = [
      "apigateway:GET",
      "apigateway:HEAD",
      "apigateway:OPTIONS",
      "autoscaling:Describe*",
      "cloudformation:Describe*",
      "cloudfront:ListDistributions",
      "cloudtrail:DescribeTrails",
      "cloudtrail:GetEventSelectors",
      "ds:GetDirectoryLimits",
      "dynamodb:Describe*",
      "dynamodb:ListTables",
      "ec2:Describe*",
      "ecs:ListClusters",
      "ecs:ListServices",
      "elasticache:DescribeCacheClusters",
      "elasticache:DescribeCacheParameterGroups",
      "elasticache:DescribeCacheSecurityGroups",
      "elasticache:DescribeCacheSubnetGroups",
      "elasticbeanstalk:Describe*",
      "elasticfilesystem:DescribeFileSystems",
      "elasticloadbalancing:Describe*",
      "firehose:ListDeliveryStreams",
      "iam:GetAccountSummary",
      "lambda:GetAccountSettings",
      "rds:Describe*",
      "redshift:DescribeClusterSnapshots",
      "redshift:DescribeClusterSubnetGroups",
      "route53:GetHostedZone",
      "route53:GetHostedZoneLimit",
      "route53:ListHostedZones",
      "s3:ListAllMyBuckets",
      "servicequotas:ListServiceQuotas",
      "ses:GetSendQuota",
      "support:*",
      "trustedadvisor:Describe*",
      "trustedadvisor:RefreshCheck"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_user" "iam_user" {
  name = var.username
}

resource "aws_iam_access_key" "iam_access_key_v4" {
  user = aws_iam_user.iam_user.name
}

resource "aws_iam_user_policy" "iam_policy" {
  name   = "${aws_iam_user.iam_user.name}-policy"
  user   = aws_iam_user.iam_user.name
  policy = data.aws_iam_policy_document.limit_check_user_policy.json
}
