module "kubernetes_node" {
  source = "../"

  role_name  = var.role_name
  iam_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Deny",
    "Action": [
      "*"
    ],
    "Resource": [
      "*"
    ]
  }
}
EOF


  iam_assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
          "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:${var.aws_partition}:iam::${var.account_id}:role${var.assume_role_path}${var.master_role}",
          "arn:${var.aws_partition}:iam::${var.account_id}:role${var.assume_role_path}${var.minion_role}"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

