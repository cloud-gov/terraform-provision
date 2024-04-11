output "domains_lbgroup_names" {
  value = aws_lb.domains_lbgroup.*.name
}

output "domains_lbgroup_target_group_apps_https_names" {
  value = aws_lb_target_group.domains_lbgroup_apps_https.*.name
}

output "domains_lbgroup_listener_arns" {
  value = aws_lb_listener.domains_lbgroup_https.*.arn
}
