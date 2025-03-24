data "aws_iam_policy_document" "health_check_user_policy" {
  statement {
    actions = [
      "cloudwatch:GetMetricData"
    ]

    resources = [
      "*"
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
  policy = data.aws_iam_policy_document.health_check_user_policy.json
}
