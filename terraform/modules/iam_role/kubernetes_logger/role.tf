module "kubernetes_logger" {
  source = ".."

  role_name = "${var.role_name}"
  iam_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Resource": [
        "arn:${var.aws_partition}:logs:${var.aws_default_region}:${var.account_id}:*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:${var.aws_partition}:logs:${var.aws_default_region}:${var.account_id}:log-group:kubernetes-*"
      ]
    }
  ]
}
EOF
}
