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
      "iam:UpdateServerCertificate",
      "iam:TagServerCertificate",
      "iam:UntagServerCertificate"
    ]
    resources = [
      "arn:aws:iam::${var.account_id}:server-certificate/cloudfront/external-domains-*",
      "arn:aws:iam::${var.account_id}:server-certificate/cloudfront/cg-*"
    ]
  }

  statement {
    actions = [
      "iam:ListServerCertificates",
    ]
    resources = [
      "arn:aws:iam::${var.account_id}:server-certificate/*"
    ]
  }

  statement {
    actions = [
      "s3:GetBucketAcl",
      "s3:PutBucketAcl"
    ]
    resources = [
      "arn:${var.aws_partition}:s3:::external-domain-broker-*"
    ]
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
  }

  statement {
    actions = [
      "route53:GetChange"
    ]
    resources = [
      "arn:${var.aws_partition}:route53:::change/*"
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
  }

  statement {
    actions = [
      "wafv2:CreateWebACL",
      "wafv2:TagResource",
      "wafv2:UntagResource"
    ]
    resources = [
      "arn:${var.aws_partition}:wafv2:${var.aws_region}:${var.account_id}:global/webacl/cg-external-domains-*"
    ]
  }

  statement {
    actions = [
      "wafv2:DeleteWebACL"
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
      "wafv2:GetRuleGroup",
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
