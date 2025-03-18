data "aws_iam_policy_document" "bosh_policy" {
  statement {
    actions = [
      "iam:PassRole"
    ]

    resources = [
      "arn:${var.aws_partition}:iam::${var.account_id}:role/bosh-passed/*"
    ]
  }

  statement {
    actions = [
      "ec2:*",
      "elasticloadbalancing:*"
    ]

    resources = [
      "*"
    ]
  }  

  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "arn:${var.aws_partition}:s3:::${var.bucket_name}",
      "arn:${var.aws_partition}:s3:::${var.bucket_name}/*"
    ]
  }    
}

resource "aws_iam_policy" "iam_policy" {
  name   = var.policy_name
  policy = data.aws_iam_policy_document.bosh_policy.json
}
