data "template_file" "policy" {
  template = "${file("${path.module}/policy.json")}"
}

module "cloudwatch_logs" {
  source = ".."

  role_name = "${var.role_name}"
  iam_policy = "${data.template_file.policy.rendered}"
}
