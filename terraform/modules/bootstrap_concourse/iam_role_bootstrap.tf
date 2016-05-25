resource "aws_iam_role" "bootstrap" {
  name = "boostrap"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
     "Action": "sts:AssumeRole",
      "Principal": {"Service": "ec2.amazonaws.com"},
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "bootstrap" {
  name = "bootstrap"
  roles = ["${aws_iam_role.bootstrap.name}"]
}

resource "aws_iam_role_policy" "bootstrap" {
  name = "bootstrap"
  role = "${aws_iam_role.bootstrap.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1464140990363",
      "Action": "*",
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}