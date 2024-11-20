data "aws_iam_policy_document" "external_domain_broker_policy" {
  statement {
    actions = [
      "iam:DeleteServerCertificate",
      "iam:UploadServerCertificate",
      "iam:UpdateServerCertificate",
      "iam:TagServerCertificate",
      "iam:UntagServerCertificate",
      "iam:GetServerCertificate"
    ]
    resources = [
      "arn:aws:iam::${var.account_id}:server-certificate/cloudfront/external-domains-*",
      "arn:aws:iam::${var.account_id}:server-certificate/cloudfront/cg-*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalArn"
      values   = [aws_iam_user.iam_user.arn]
    }
  }

  statement {
    actions = [
      "iam:ListServerCertificates",
    ]
    resources = [
      "arn:aws:iam::${var.account_id}:server-certificate/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalArn"
      values   = [aws_iam_user.iam_user.arn]
    }
  }

  # this permission is required for wafv2:PutLoggingConfiguration
  # see https://docs.aws.amazon.com/service-authorization/latest/reference/list_awswafv2.html#awswafv2-actions-as-permissions
  statement {
    actions = [
      "iam:CreateServiceLinkedRole"
    ]
    resources = [
      "arn:aws:iam::${var.account_id}:role/aws-service-role/wafv2.amazonaws.com/AWSServiceRoleForWAFV2Logging"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalArn"
      values   = [aws_iam_user.iam_user.arn]
    }
  }

  statement {
    actions = [
      "s3:GetBucketAcl",
      "s3:PutBucketAcl"
    ]
    resources = [
      "arn:${var.aws_partition}:s3:::external-domain-broker-*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalArn"
      values   = [aws_iam_user.iam_user.arn]
    }
  }

  statement {
    actions = [
      "cloudfront:CreateDistribution",
      "cloudfront:UpdateDistribution",
      "cloudfront:DeleteDistribution",
      "cloudfront:GetDistribution",
      "cloudfront:GetDistributionConfig",
      "cloudfront:TagResource",
      "cloudfront:UntagResource"
    ]
    resources = [
      "arn:${var.aws_partition}:cloudfront::${var.account_id}:distribution/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalArn"
      values   = [aws_iam_user.iam_user.arn]
    }
  }

  statement {
    actions = [
      "route53:GetChange"
    ]
    resources = [
      "arn:${var.aws_partition}:route53:::change/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalArn"
      values   = [aws_iam_user.iam_user.arn]
    }
  }

  statement {
    actions = [
      "route53:ChangeResourceRecordSets"
    ]
    resources = [
      "arn:aws:route53:::hostedzone/${aws_route53_zone.zone.zone_id}"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalArn"
      values   = [aws_iam_user.iam_user.arn]
    }
  }
}

data "aws_iam_policy_document" "external_domain_broker_manage_protections_policy" {
  statement {
    actions = [
      "shield:AssociateHealthCheck",
      "shield:DisassociateHealthCheck"
    ]
    resources = [
      "arn:${var.aws_partition}:shield::${var.account_id}:protection/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalArn"
      values   = [aws_iam_user.iam_user.arn]
    }
  }

  statement {
    actions = [
      "shield:ListProtections",
    ]
    resources = [
      "*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalArn"
      values   = [aws_iam_user.iam_user.arn]
    }
  }

  statement {
    actions = [
      "wafv2:CreateWebACL",
    ]
    resources = [
      "arn:${var.aws_partition}:wafv2:${var.aws_region}:${var.account_id}:global/webacl/cg-external-domains-*",
      aws_wafv2_rule_group.rate_limit_group.arn
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalArn"
      values   = [aws_iam_user.iam_user.arn]
    }
  }

  statement {
    actions = [
      "wafv2:TagResource",
      "wafv2:UntagResource",
      "wafv2:DeleteWebACL",
      "wafv2:GetWebACL"
    ]
    resources = [
      "arn:${var.aws_partition}:wafv2:${var.aws_region}:${var.account_id}:global/webacl/cg-external-domains-*",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalArn"
      values   = [aws_iam_user.iam_user.arn]
    }
  }

  statement {
    actions = [
      "wafv2:PutLoggingConfiguration",
      "wafv2:DeleteLoggingConfiguration"
    ]
    resources = [
      "arn:${var.aws_partition}:wafv2:${var.aws_region}:${var.account_id}:global/webacl/cg-external-domains-*",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalArn"
      values   = [aws_iam_user.iam_user.arn]
    }
    condition {
      test     = "ArnLike"
      variable = "wafv2:LogDestinationResource"
      values   = [aws_cloudwatch_log_group.external_domain_waf_logs.arn]
    }
  }

  # necessary permissions for sending WAF logs to CloudWatch
  # see https://docs.aws.amazon.com/waf/latest/developerguide/logging-cw-logs.html#logging-cw-logs-permissions
  #
  # wildcard permissions are required for these actions
  # see https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazoncloudwatchlogs.html#amazoncloudwatchlogs-actions-as-permissions
  statement {
    actions = [
      "logs:CreateLogDelivery",
      "logs:DeleteLogDelivery",
      "logs:PutResourcePolicy",
      "logs:DescribeResourcePolicies",
      "logs:DescribeLogGroups"
    ]
    resources = [
      "*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalArn"
      values   = [aws_iam_user.iam_user.arn]
    }
  }

  statement {
    actions = [
      "wafv2:GetRuleGroup",
    ]
    resources = [
      aws_wafv2_rule_group.rate_limit_group.arn
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalArn"
      values   = [aws_iam_user.iam_user.arn]
    }
  }

  statement {
    actions = [
      "route53:CreateHealthCheck",
    ]
    # Wildcard for the resource constraint is required for CreateHealthCheck
    # see https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazonroute53.html
    resources = [
      "*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalArn"
      values   = [aws_iam_user.iam_user.arn]
    }
  }

  statement {
    actions = [
      "route53:DeleteHealthCheck",
      "route53:GetHealthCheck",
      "route53:ChangeTagsForResource",
      "route53:UpdateHealthCheck"
    ]
    resources = [
      "arn:${var.aws_partition}:route53:::healthcheck/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalArn"
      values   = [aws_iam_user.iam_user.arn]
    }
  }

  statement {
    actions = [
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:DeleteAlarms"
    ]
    resources = [
      "arn:${var.aws_partition}:cloudwatch:${var.aws_region}:${var.account_id}:alarm:cg-external-domains-*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalArn"
      values   = [aws_iam_user.iam_user.arn]
    }
  }

  statement {
    actions = [
      "sns:CreateTopic",
      "sns:DeleteTopic",
      "sns:TagResource",
      "sns:UntagResource",
      "sns:Subscribe",
      "sns:Unsubscribe"
    ]
    resources = [
      "arn:${var.aws_partition}:sns:${var.aws_region}:${var.account_id}:cg-external-domains-*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalArn"
      values   = [aws_iam_user.iam_user.arn]
    }
  }
}

resource "aws_iam_user" "iam_user" {
  name = "external-domain-broker-${var.stack_description}"
}

resource "aws_iam_access_key" "iam_access_key_v3" {
  user = aws_iam_user.iam_user.name
}

resource "aws_iam_policy" "base_policy" {
  name   = "${aws_iam_user.iam_user.name}-policy"
  policy = data.aws_iam_policy_document.external_domain_broker_policy.json
}

resource "aws_iam_user_policy_attachment" "attach_base_policy" {
  user       = aws_iam_user.iam_user.name
  policy_arn = aws_iam_policy.base_policy.arn
}

resource "aws_iam_policy" "manage_protections_policy" {
  name   = "${aws_iam_user.iam_user.name}-manage-protections-policy"
  policy = data.aws_iam_policy_document.external_domain_broker_manage_protections_policy.json
}

resource "aws_iam_user_policy_attachment" "attach_manage_protections_policy" {
  user       = aws_iam_user.iam_user.name
  policy_arn = aws_iam_policy.manage_protections_policy.arn
}
