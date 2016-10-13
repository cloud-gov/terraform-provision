variable "role_name" {}

variable "role_path" {
  default = "/bosh-passed/"
}

variable "iam_policy" {}

variable "iam_assume_role_policy" {
  default = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}
