data "template_file" "policy" {
  template = "${file("${path.module}/policy.json")}"

  vars {
    aws_partition = "${var.aws_partition}"
    varz_bucket = "${var.varz_bucket}"
    varz_staging_bucket = "${var.varz_staging_bucket}"
    stemcell_bucket = "${var.stemcell_bucket}"
    terraform_state_bucket = "${var.terraform_state_bucket}"
  }
}

resource "aws_iam_role_policy" "iam_policy" {
  name = "${var.policy_name}"
  policy = "${data.template_file.policy.rendered}"
}
