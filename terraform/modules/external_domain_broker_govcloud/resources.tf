# These resources are for https://github.com/cloud-gov/external-domain-broker
# Note that the broker needs both commercial and govcloud users because it operates
# on both commercial (cloudfront, route53) and govcloud (alb) resources

data "template_file" "policy" {
  template = file("${path.module}/policy.json")

  vars = {
    account_id      = var.account_id
    stack           = var.stack_description
    iam_cert_prefix = var.iam_cert_prefix
  }
}

resource "aws_iam_user" "iam_user" {
  name = "external-domain-broker-gov-${var.stack_description}"
}

resource "aws_iam_access_key" "iam_access_key_v1" {
  user = aws_iam_user.iam_user.name
}

resource "aws_iam_access_key" "iam_access_key_v2" {
  user = aws_iam_user.iam_user.name
}

resource "aws_iam_user_policy" "iam_policy" {
  name   = "${aws_iam_user.iam_user.name}-policy"
  user   = aws_iam_user.iam_user.name
  policy = data.template_file.policy.rendered
}

