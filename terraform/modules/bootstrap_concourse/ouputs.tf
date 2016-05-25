output "endpoint" {
  value = "https://${var.concourse_username}:${var.concourse_password}@${aws_instance.bootstrap_concourse.public_dns}/login/basic"
}
