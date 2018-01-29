output "security_group" {
  value = "${aws_security_group.dns.id}"
}
