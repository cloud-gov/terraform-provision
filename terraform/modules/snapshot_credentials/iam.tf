resource "aws_iam_user" "snapshot" {
  name = var.resource_prefix
  path = "/snapshot/"

  tags = local.merged_tags
}

data "aws_iam_policy_document" "snapshot_s3" {
  statement {
    sid    = "SnapshotObjectAccess"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]

    resources = [
      "${var.bucket}/*",
    ]
  }
  statement {
    sid    = "SnapshotBucketList"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]

    resources = [
      var.bucket,
    ]
  }
}

resource "aws_iam_policy" "snapshot_s3" {
  name        = "${var.resource_prefix}-s3-policy"
  description = "Grants snapshot S3 access (get/put/delete/list) for ${var.resource_prefix}"
  policy      = data.aws_iam_policy_document.snapshot_s3.json

  tags = local.merged_tags
}

resource "aws_iam_user_policy_attachment" "snapshot" {
  user       = aws_iam_user.snapshot.name
  policy_arn = aws_iam_policy.snapshot_s3.arn
}

resource "aws_iam_access_key" "snapshot" {
  user = aws_iam_user.snapshot.name

}
