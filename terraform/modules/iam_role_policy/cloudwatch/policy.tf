data "template_file" "policy" {
  template = "${file("${path.module}/policy.json")}"
}

resource "aws_iam_role_policy" "iam_policy" {
  name = "${var.policy_name}"
  policy = "${data.template_file.policy.rendered}"
}
