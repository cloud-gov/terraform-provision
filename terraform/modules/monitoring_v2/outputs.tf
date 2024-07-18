output "monitoring_subnet_ids" {
  value = aws_subnet.monitoring_subnet[*].id
}

output "monitoring_cidrs" {
  value = aws_subnet.monitoring_subnet[*].cidr_block
}

output "monitoring_availability_zones" {
  value = var.monitoring_availability_zones
}

output "monitoring_security_group" {
  value = aws_security_group.monitoring.id
}

output "lb_target_group" {
  value = aws_lb_target_group.prometheus_target.name
}

# doomsday lb target.
output "doomsday_lb_target_group" {
  value = aws_lb_target_group.doomsday_target.name
}
