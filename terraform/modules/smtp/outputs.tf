output "smtp_inbound_security_group" {
  value = "${aws_security_group.smtp_inbound.id}"
}
