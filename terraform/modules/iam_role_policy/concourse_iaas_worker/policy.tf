data "template_file" "policy" {
  template = "${file("${path.module}/policy.json")}"
}

// Grant IAAS worker admin permissions without using predefined `AdministratorAccess` policy
// so that terraform errors won't affect operator permissions
resource "aws_iam_policy" "iam_policy" {
  name = "${var.policy_name}"
  policy = "${data.template_file.policy.rendered}"
}
