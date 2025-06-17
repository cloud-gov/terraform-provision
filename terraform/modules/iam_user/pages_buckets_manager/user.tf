data "aws_iam_policy_document" "pages_buckets_manager_policy" {
  statement {
    actions = [
      "s3:*",
    ]

    resources = [
      "arn:aws:s3:::${var.bucket_prefix}-*",
      "arn:aws:s3:::${var.bucket_prefix}-*/*"
    ]
  }
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
  policy = data.aws_iam_policy_document.pages_buckets_manager_policy.json
}
