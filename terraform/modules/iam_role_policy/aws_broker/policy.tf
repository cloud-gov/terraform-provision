data "template_file" "policy" {
  template = "${file("${path.module}/policy.json")}"

  vars {
    account_id = "${var.account_id}"
    aws_default_region = "${var.aws_default_region}"
    aws_partition = "${var.aws_partition}"
    remote_state_bucket = "${var.remote_state_bucket}"
    rds_subgroup = "${var.rds_subgroup}"
    iam_path = "${var.iam_path}"
  }
}

resource "aws_iam_policy" "iam_policy" {
  name = "${var.policy_name}"
  policy = "${data.template_file.policy.rendered}"
}
