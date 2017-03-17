output "static_ip" {
  value = "${aws_eip.static_ip.public_ip}"
}
