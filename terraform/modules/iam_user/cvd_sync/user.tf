data "aws_iam_policy_document" "cvd_sync_user_policy" {
  statement {
    actions = [
      "s3:ListAllMyBuckets"
    ]

    resources = [
      "arn:${var.aws_partition}:s3:::*"
    ]
  }

  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    resources = [
      "arn:${var.aws_partition}:s3:::${var.cvd_database_bucket}",
      "arn:${var.aws_partition}:s3:::${var.cvd_metadata_bucket}"
    ]
  }

  statement {
    actions = [
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:GetBucketVersioning",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
      "s3:ListBucketMultipartUploads",
      "s3:ListBucketVersions",
      "s3:ListMultipartUploadParts",
      "s3:PutObject"
    ]

    resources = [
      "arn:${var.aws_partition}:s3:::${var.cvd_database_bucket}/*",
      "arn:${var.aws_partition}:s3:::${var.cvd_metadata_bucket}/*"
    ]
  }
}

resource "aws_iam_user" "iam_user" {
  name = var.username
}

resource "aws_iam_access_key" "iam_access_key_v2" {
  user = aws_iam_user.iam_user.name
}

resource "aws_iam_user_policy" "iam_policy" {
  name   = "${aws_iam_user.iam_user.name}-policy"
  user   = aws_iam_user.iam_user.name
  policy = data.aws_iam_policy_document.cvd_sync_user_policy.json
}
