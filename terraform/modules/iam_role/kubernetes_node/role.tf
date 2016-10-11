# TODO: Remove `CreateTags` permission https://github.com/cloudfoundry-incubator/bosh-aws-cpi-release/issues/33 is resolved

module "kubernetes_node" {
  source = ".."

  role_name = "${var.role_name}"
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
}
