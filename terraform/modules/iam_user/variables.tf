variable "username" {}

variable "iam_policy" {
  default = <<EOF
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
}
