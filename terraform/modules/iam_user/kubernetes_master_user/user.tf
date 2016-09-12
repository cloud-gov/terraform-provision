module "kubernetes_master_user" {
  source = ".."

  username = "${var.username}"
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
    }
  ]
}
EOF
}
