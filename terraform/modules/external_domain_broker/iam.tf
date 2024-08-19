locals {
  broker_tag_values = [
    "External domain broker",
  ]
}

data "aws_iam_policy_document" "external_domain_broker_policy" {
  statement {
    actions = [
      "iam:DeleteServerCertificate",
      "iam:UploadServerCertificate",
      "iam:UpdateServerCertificate"
    ]
    resources = [
      "arn:aws:iam::${account_id}:server-certificate/cloudfront/external-domains-*",
      "arn:aws:iam::${account_id}:server-certificate/cloudfront/cg-*"
    ]
  }

  statement {
    actions = [
      "iam:ListServerCertificates",
    ]
    resources = [
      "arn:aws:iam::${account_id}:server-certificate/*"
    ]
  }

  statement {
    actions = [
      "s3:GetBucketAcl",
      "s3:PutBucketAcl"
    ]
    resources = [
      "arn:${aws_partition}:s3:::external-domain-broker-*"
    ]
  }

  statement {
    actions = [
      "cloudfront:CreateDistributionWithTags",
      "cloudfront:CreateDistribution",
      "cloudfront:UpdateDistribution",
      "cloudfront:DeleteDistribution",
      "cloudfront:GetDistributionConfig"
    ]
    resources = [
      "arn:${var.aws_partition}:cloudfront::${var.account_id}:distribution/*"
    ]
  }

  statement {
    actions = [
      "route53:GetChange"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "route53:ChangeResourceRecordSets"
    ]
    resources = [
      "arn:aws:route53:::hostedzone/${aws_route53_zone.zone.zone_id}"
    ]
  }

  statement {
    actions = [
      "shield:AssociateHealthCheck",
      "shield:DisassociateHealthCheck"
    ]
    resources = [
      "arn:${var.aws_partition}:shield::${var.account_id}:protection/*"
    ]
  }

  statement {
    actions = [
      "waf:CreateWebACL"
    ]
    resources = [
      "arn:${var.aws_partition}:wafv2:${var.aws_region}:${var.account_id}:global/webacl/cg-external-domains-*/*"
    ]
  }

  statement {
    actions = [
      "waf:DeleteWebACL"
    ]
    resources = [
      "arn:${var.aws_partition}:wafv2:${var.aws_region}:${var.account_id}:global/webacl/cg-external-domains-*/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/broker"
      values   = local.broker_tag_values
    }
  }

  statement {
    actions = [
      "waf:GetRuleGroup",
    ]
    resources = [
      aws_wafv2_rule_group.rate_limit_group.arn
    ]
  }

  statement {
    actions = [
      "route53:CreateHealthCheck",
      "route53:GetHealthCheck"
    ]
    resources = [
      "arn:${var.aws_partition}:route53:::healthcheck/*"
    ]
  }

  statement {
    actions = [
      "route53:DeleteHealthCheck",
      "route53:UpdateHealthCheck"
    ]
    resources = [
      "arn:${var.aws_partition}:route53:::healthcheck/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/broker"
      values   = local.broker_tag_values
    }
  }
}

resource "aws_iam_user" "iam_user" {
  name = "external-domain-broker-${var.stack_description}"
}

resource "aws_iam_access_key" "iam_access_key_v3" {
  user = aws_iam_user.iam_user.name
}

resource "aws_iam_user_policy" "iam_policy" {
  name   = "${aws_iam_user.iam_user.name}-policy"
  user   = aws_iam_user.iam_user.name
  policy = data.aws_iam_policy_document.external_domain_broker_policy.json
}
