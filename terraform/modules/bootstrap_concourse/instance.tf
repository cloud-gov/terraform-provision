resource "template_file" "pipeline" {
    template = "${file("${path.module}/assets/pipeline.yml")}"

    vars {
        aws_access_key_id = "${var.aws_access_key_id}"
        aws_secret_access_key = "${var.aws_secret_access_key}"
        aws_default_region = "${var.aws_default_region}"
        account_id = "${var.account_id}"
        remote_state_bucket = "${var.remote_state_bucket}"
        credentials_bucket = "${var.credentials_bucket}"
        concourse_username = "${var.concourse_username}"
        concourse_password = "${var.concourse_password}"
        default_vpc_id = "${var.default_vpc_id}"
        default_vpc_cidr = "${var.default_vpc_cidr}"
        default_vpc_route_table = "${var.default_vpc_route_table}"
    }
}

resource "aws_instance" "bootstrap_concourse" {
  ami = "${var.ami_id}"
  instance_type = "${var.instance_type}"

  security_groups = ["${aws_security_group.bootstrap.name}"]

  iam_instance_profile = "${aws_iam_instance_profile.bootstrap.id}"

  user_data = <<EOF
username: ${var.concourse_username}
password: ${var.concourse_password}
pipeline: |
${template_file.pipeline.rendered}
EOF

  connection {
    user = "ubuntu"
  }

}

