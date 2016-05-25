output "endpoint" {
  value = "http://${var.concourse_username}:${var.concourse_password}@${aws_instance.bootstrap_concourse.public_ip}/login/basic"
}
