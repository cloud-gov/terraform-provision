resource "template_file" "pipeline" {
    template = "${file("${path.module}/assets/pipeline.yml")}"

    vars {
        aws_default_region = "${var.region}"
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
