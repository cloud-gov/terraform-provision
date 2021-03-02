output "admin_lb_name" {
  value = aws_lb.admin.name
}

output "admin_lb_dns_name" {
  value = aws_lb.admin.dns_name
}

output "admin_lb_target_group" {
  value = aws_lb_target_group.admin.name
}

