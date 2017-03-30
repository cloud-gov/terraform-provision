data "template_file" "policy" {
  template = "${file("${path.module}/policy.json")}"

  vars {
    aws_partition = "${var.aws_partition}"
    bucket_name = "${var.bucket_name}"
  }
}

module "blobstore" {
  source = ".."

  role_name = "${var.role_name}"
  iam_policy = "${data.template_file.policy.rendered}"
}
