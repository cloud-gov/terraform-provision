data "template_file" "policy" {
  template = "${file("${path.module}/policy.json")}"

  vars {
    aws_partition = "${var.aws_partition}"
    aws_default_region = "${var.aws_default_region}"
    account_id = "${var.account_id}"
  }
}

module "riemann_monitoring" {
  source = ".."

  role_name = "${var.role_name}"

  iam_policy = "${data.template_file.policy.rendered}"
}


