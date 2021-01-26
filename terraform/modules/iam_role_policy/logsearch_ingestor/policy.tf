data "template_file" "policy" {
  template = "${file("${path.module}/policy.json")}"

  vars = {
    account_id = "${var.account_id}"
    aws_partition = "${var.aws_partition}"
    aws_default_region = "${var.aws_default_region}"
  }
}

resource "aws_iam_policy" "iam_policy" {
  name = "${var.policy_name}"
  policy = "${data.template_file.policy.rendered}"
}
