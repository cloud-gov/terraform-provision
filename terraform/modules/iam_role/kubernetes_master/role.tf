# TODO: Remove `CreateTags` permission https://github.com/cloudfoundry-incubator/bosh-aws-cpi-release/issues/33 is resolved

module "kubernetes_master" {
  source = ".."

  role_name = "${var.role_name}"
  iam_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["ec2:*"],
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": ["elasticloadbalancing:*"],
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": [
        "arn:${var.aws_partition}:s3:::kubernetes-*"
      ]
    },
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
    },
    {
      "Effect": "Allow",
      "Action": "ec2:CreateTags",
      "Resource": "*"
    }
  ]
}
EOF
}
