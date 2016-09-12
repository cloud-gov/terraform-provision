resource "aws_iam_policy" "k8s_master" {
  name = "k8s-master"
  policy = <<EOF
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

resource "aws_iam_policy" "k8s_minion" {
  name = "k8s-minion"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": [
        "arn:${var.aws_partition}:s3:::kubernetes-*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": "ec2:Describe*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "ec2:AttachVolume",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "ec2:DetachVolume",
      "Resource": "*"
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

resource "aws_iam_role" "k8s_master" {
  name = "k8s-master"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role" "k8s_minion" {
  name = "k8s-minion"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "k8s_master_attachment" {
  role = "${aws_iam_role.k8s_master.name}"
  policy_arn = "${aws_iam_policy.k8s_master.arn}"
}

resource "aws_iam_role_policy_attachment" "k8s_minion_attachment" {
  role = "${aws_iam_role.k8s_minion.name}"
  policy_arn = "${aws_iam_policy.k8s_minion.arn}"
}
