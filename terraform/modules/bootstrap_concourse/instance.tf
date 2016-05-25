resource "aws_instance" "bootstrap_concourse" {
  ami = "${var.ami_id}"
  instance_type = "${var.instance_type}"

  key_name = "${aws_key_pair.auth.id}"

  security_groups = ["${aws_security_group.bootstrap.name}"]

  iam_instance_profile = "${aws_iam_instance_profile.bootstrap.id}"

  user_data = <<EOF
username: ${var.concourse_username}
password: ${var.concourse_password}
pipeline: |
${file("${path.module}/assets/pipeline.yml")}
EOF

  connection {
    user = "ubuntu"
  }

}
