output "monitoring_subnet" {
  value = "${aws_subnet.monitoring.id}"
}

output "monitoring_az" {
  value = "${var.monitoring_az}"
}

output "monitoring_security_group" {
  value = "${aws_security_group.monitoring.id}"
}

output "lb_target_group" {
  value = "${aws_lb_target_group.prometheus_target.name}"
}
