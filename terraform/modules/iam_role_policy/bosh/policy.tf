data "template_file" "policy" {
  template = "${file("${path.module}/policy.json")}"

  vars = {
    aws_partition = "${var.aws_partition}"
    account_id = "${var.account_id}"
    bucket_name = "${var.bucket_name}"
  }
}

resource "aws_iam_policy" "iam_policy" {
  name = "${var.policy_name}"
  policy = "${data.template_file.policy.rendered}"
}
