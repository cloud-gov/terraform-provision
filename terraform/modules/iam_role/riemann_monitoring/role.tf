module "riemann_monitoring" {
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
        "ec2:DescribeInstances",
        "ec2:CreateSnapshot",
        "ec2:CreateTags"
      ],
      "Resource": [
        "*"
      ]
    },
    {
        "Effect": "Allow",
        "Action": [
            "ec2:StopInstances"
        ],
        "Resource": [
          "arn:${var.aws_partition}:ec2:${var.aws_default_region}:${var.account_id}:*"
        ]
    }
  ]
}
EOF
}


