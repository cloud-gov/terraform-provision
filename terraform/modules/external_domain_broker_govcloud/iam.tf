# These resources are for https://github.com/cloud-gov/external-domain-broker
# Note that the broker needs both commercial and govcloud users because it operates
# on both commercial (cloudfront, route53) and govcloud (alb) resources

data "aws_iam_policy_document" "external_domain_broker_policy" {
  statement {
    actions = [
      "iam:UploadServerCertificate",
      "iam:DeleteServerCertificate",
      "iam:TagServerCertificate",
      "iam:UntagServerCertificate",
    ]
    resources = [
      "arn:aws-us-gov:iam::${var.account_id}:server-certificate/alb/external-domains-*",
      "arn:aws-us-gov:iam::${var.account_id}:server-certificate/domains*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalArn"
      values   = [aws_iam_user.iam_user.arn]
    }
    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = var.environment_nat_egress_ips
    }
  }

  statement {
    actions = [
      "iam:GetServerCertificate"
    ]
    resources = [
      "arn:aws-us-gov:iam::${var.account_id}:server-certificate/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalArn"
      values   = [aws_iam_user.iam_user.arn]
    }
    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = var.environment_nat_egress_ips
    }
  }


  statement {
    actions = [
      "iam:ListServerCertificates",
    ]
    resources = [
      "*",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalArn"
      values   = [aws_iam_user.iam_user.arn]
    }
    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = var.environment_nat_egress_ips
    }
  }

  statement {
    actions = [
      "elasticloadbalancing:AddListenerCertificates",
      "elasticloadbalancing:RemoveListenerCertificates"
    ]
    resources = [
      "arn:${var.aws_partition}:elasticloadbalancing:${var.aws_region}:${var.account_id}:listener/app/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalArn"
      values   = [aws_iam_user.iam_user.arn]
    }
    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = var.environment_nat_egress_ips
    }
  }

  statement {
    actions = [
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeListenerCertificates",
      "elasticloadbalancing:DescribeLoadBalancers"
    ]
    resources = [
      "*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalArn"
      values   = [aws_iam_user.iam_user.arn]
    }
    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = var.environment_nat_egress_ips
    }
  }

  # this permission is required for wafv2:PutLoggingConfiguration
  # see https://docs.aws.amazon.com/service-authorization/latest/reference/list_awswafv2.html#awswafv2-actions-as-permissions
  statement {
    actions = [
      "iam:CreateServiceLinkedRole"
    ]
    resources = [
      "arn:${var.aws_partition}:iam::${var.account_id}:role/aws-service-role/wafv2.amazonaws.com/AWSServiceRoleForWAFV2Logging"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalArn"
      values   = [aws_iam_user.iam_user.arn]
    }
    condition {
      test     = "StringLike"
      variable = "iam:AWSServiceName"
      values   = ["wafv2.amazonaws.com"]
    }
    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = var.environment_nat_egress_ips
    }
  }

  statement {
    actions = [
      "wafv2:CreateWebACL"
    ]
    resources = [
      "arn:${var.aws_partition}:wafv2:${var.aws_region}:${var.account_id}:regional/webacl/cg-external-domains-*",
      "arn:${var.aws_partition}:wafv2:${var.aws_region}:${var.account_id}:regional/managedruleset/*/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalArn"
      values   = [aws_iam_user.iam_user.arn]
    }
    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = var.environment_nat_egress_ips
    }
  }

  statement {
    actions = [
      "wafv2:TagResource",
      "wafv2:UntagResource",
      "wafv2:GetWebACL",
      "wafv2:AssociateWebACL"
    ]
    resources = [
      "arn:${var.aws_partition}:wafv2:${var.aws_region}:${var.account_id}:regional/webacl/cg-external-domains-*",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalArn"
      values   = [aws_iam_user.iam_user.arn]
    }
    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = var.environment_nat_egress_ips
    }
  }

  statement {
    actions = [
      "wafv2:GetWebACLForResource"
    ]
    resources = [
      "arn:${var.aws_partition}:wafv2:${var.aws_region}:${var.account_id}:regional/webacl/*/*",
      "arn:${var.aws_partition}:elasticloadbalancing:${var.aws_region}:${var.account_id}:loadbalancer/app/${var.stack_description}-domains-lbgroup-*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalArn"
      values   = [aws_iam_user.iam_user.arn]
    }
    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = var.environment_nat_egress_ips
    }
  }

  statement {
    actions = [
      "wafv2:DeleteWebACL"
    ]
    resources = [
      "arn:${var.aws_partition}:wafv2:${var.aws_region}:${var.account_id}:regional/webacl/cg-external-domains-${var.stack_description}*",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalArn"
      values   = [aws_iam_user.iam_user.arn]
    }
    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = var.environment_nat_egress_ips
    }
  }

  statement {
    actions = [
      "wafv2:ListWebACLs"
    ]
    resources = [
      "*",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalArn"
      values   = [aws_iam_user.iam_user.arn]
    }
    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = var.environment_nat_egress_ips
    }
  }

  statement {
    actions = [
      "wafv2:PutLoggingConfiguration",
      "wafv2:DeleteLoggingConfiguration"
    ]
    resources = [
      "arn:${var.aws_partition}:wafv2:${var.aws_region}:${var.account_id}:regional/webacl/cg-external-domains-*",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalArn"
      values   = [aws_iam_user.iam_user.arn]
    }
    condition {
      test     = "ArnLike"
      variable = "wafv2:LogDestinationResource"
      values   = [var.waf_log_group_arn]
    }
    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = var.environment_nat_egress_ips
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
    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = var.environment_nat_egress_ips
    }
  }

  # this permission can only use "*" as its resource constraint
  # see https://docs.aws.amazon.com/service-authorization/latest/reference/list_awselasticloadbalancingv2.html
  statement {
    actions = [
      "elasticloadbalancing:SetWebACL"
    ]
    resources = [
      "*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalArn"
      values   = [aws_iam_user.iam_user.arn]
    }
    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = var.environment_nat_egress_ips
    }
  }
}

resource "aws_iam_user" "iam_user" {
  name = "external-domain-broker-gov-${var.stack_description}"
}

resource "aws_iam_access_key" "iam_access_key_v1" {
  user = aws_iam_user.iam_user.name
}
resource "aws_iam_access_key" "iam_access_key_v2" {
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
