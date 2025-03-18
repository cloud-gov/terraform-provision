module "cdn_broker_bucket" {
  source        = "../s3_bucket/public_encrypted_bucket"
  bucket        = var.bucket
  aws_partition = var.aws_partition
}

data "aws_route53_zone" "zone" {
  name = var.hosted_zone
}

data "aws_iam_policy_document" "cdn_broker_policy" {
  statement {
    actions = [
      "iam:DeleteServerCertificate",
      "iam:ListServerCertificates",
      "iam:UploadServerCertificate",
      "iam:UpdateServerCertificate"
    ]

    resources = ["arn:${var.aws_partition}:iam::${var.account_id}:server-certificate/cloudfront/${var.cloudfront_prefix}"]
  }

  statement {
    actions = [
      "cloudfront:*"
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = ["arn:${var.aws_partition}:s3:::${var.bucket}/*"]
  }

  statement {
    actions = [
      "route53:ChangeResourceRecordSets"
    ]

    resources = ["arn:${var.aws_partition}:route53:::hostedzone/${data.aws_route53_zone.zone.zone_id}"]
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
  policy = data.aws_iam_policy_document.cdn_broker_policy.json
}
