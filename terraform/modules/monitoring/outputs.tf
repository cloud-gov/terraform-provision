output "monitoring_subnet" {
  value = "${aws_subnet.monitoring.id}"
}

output "monitoring_cidr" {
  value = "${aws_subnet.monitoring.cidr_block}"
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

# doomsday lb target.
output "doomsday_lb_target_group" {
  value = "${aws_lb_target_group.doomsday_target.name}"
}
