module "influxdb_archive" {
  source = ".."

  role_name = "${var.role_name}"
  iam_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:ListObjects"
            ],
            "Resource": [
                "arn:${var.aws_partition}:s3:::influxdb-*/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:${var.aws_partition}:s3:::influxdb-*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstances",
                "ec2:DescribeVPCs"
            ],

            "Resource": "*"
        }
    ]
}
EOF
}
