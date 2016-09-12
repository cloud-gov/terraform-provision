
module "bosh_user" {
    source = ".."

    username = "${var.username}"
    iam_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Deny",
        "Action": [
            "iam:*"
        ],
        "Resource": [
            "*"
        ]
    },
    {
        "Sid": "PassIAMRoles",
        "Effect": "Allow",
        "Action": [
            "iam:PassRole"
        ],
        "Resource": [
            "arn:${var.aws_partition}:iam::${var.account_id}:role/k8s-*"
        ]
    },
    {
        "Sid": "S3Access",
        "Effect": "Allow",
        "Action": [
            "s3:*"
        ],
        "Resource": [
            "*"
        ]
    },
    {
        "Sid": "BoshDeployments",
        "Effect": "Allow",
        "Action": [
            "ec2:*",
            "elasticloadbalancing:*"
        ],
        "Resource": [
            "*"
        ]
    }
  ]
}
EOF
}
