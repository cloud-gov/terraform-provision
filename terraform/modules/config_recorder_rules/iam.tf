resource "aws_iam_role" "aws_config_role" {
  name = "${var.stack_prefix}-config-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "config_bucket_access_policy" {
  name = "${stack_prefix}-config-bucket-access-policy"
  role = aws_iam_role.r.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "${module.config_results_bucket.bucket_arn}",
        "${module.config_results_bucket.bucket_arn}/*"
      ]
    }
  ]
}
POLICY
}