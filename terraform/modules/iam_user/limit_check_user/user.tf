data "template_file" "policy" {
  template = "${file("${path.module}/policy.json")}"
}

module "limit_check_user" {
  source = ".."

  username = "${var.username}"
  iam_policy = "${data.template_file.policy.rendered}"
}
