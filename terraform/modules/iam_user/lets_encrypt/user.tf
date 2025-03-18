data "aws_iam_policy_document" "lets_encrypt_policy" {
  statement {
    actions = [
      "route53:ListHostedZones",
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
      "arn:${var.aws_partition}:route53:::hostedzone/${data.aws_route53_zone.zone.zone_id}"
    ]
  }  
}

data "aws_route53_zone" "zone" {
  name = var.hosted_zone
}

resource "aws_iam_user" "iam_user" {
  name = var.username
}

resource "aws_iam_access_key" "iam_access_key_v3" {
  user = aws_iam_user.iam_user.name
}

resource "aws_iam_user_policy" "iam_policy" {
  name   = "${aws_iam_user.iam_user.name}-policy"
  user   = aws_iam_user.iam_user.name
  policy = data.aws_iam_policy_document.lets_encrypt_policy.json
}
