data "aws_iam_policy_document" "iam_cert_provision_policy" {
  statement {
    actions = [
      "iam:ListServerCertificates",
      "iam:UploadServerCertificate",
      "iam:DeleteServerCertificate"
    ]

    resources = [
      "arn:${var.aws_partition}:iam::${var.account_id}:server-certificate/lets-encrypt/*"
    ]
  }

  statement {
    actions = [
      "sts:AssumeRole"
    ]

    resources = [
      "arn:${var.aws_partition}:iam::*:role/terraform/*-tooling-cert-uploader"
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
  policy = data.aws_iam_policy_document.iam_cert_provision_policy.json
}
