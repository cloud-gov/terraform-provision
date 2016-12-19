data "template_file" "policy" {
  template = "${file("${path.module}/policy.json")}"

  vars {
    aws_partition = "${var.aws_partition}"
    account_id = "${var.account_id}"
  }
}

module "go_s3_broker_user" {
  source = ".."

  username = "${var.username}"
  iam_policy = "${data.template_file.policy.rendered}"
}
