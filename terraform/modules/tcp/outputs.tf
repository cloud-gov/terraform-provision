output "tcp_lb_names" {
  value = aws_lb.cf_apps_tcp.name
}

output "tcp_lb_dns_names" {
  value = aws_lb.cf_apps_tcp.dns_name
}

output "tcp_lb_target_groups" {
  value = aws_lb_target_group.cf_apps_target_tcp.*.name
}

output "tcp_lb_listener_ports" {
  value = aws_lb_listener.cf_apps_tcp.*.port
}

output "tcp_lb_security_group" {
  value = aws_security_group.nlb_traffic
}
