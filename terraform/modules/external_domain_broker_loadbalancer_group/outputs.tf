output "domains_lbgroup_names" {
  value = aws_lb.domains_lbgroup.*.name
}

output "domains_lbgroup_target_group_apps_https_names" {
  value = aws_lb_target_group.domains_lbgroup_apps_https.*.name
}

output "domains_lbgroup_listener_arns" {
  value = aws_lb_listener.domains_lbgroup_https.*.arn
}

output "domains_lbgroup_target_group_logstash_https_names" {
  value = aws_lb_target_group.domains_lbgroup_logstash_https.*.name
}

output "domains_lbgroup_target_group_gr_apps_https_names" {
  value = aws_lb_target_group.domains_lbgroup_gr_apps_https.*.name
}

output "domains_lbgroup_target_group_gr_logstash_https_names" {
  value = aws_lb_target_group.domains_lbgroup_gr_logstash_https.*.name
}
