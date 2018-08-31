output "admin_lb_target_group" {
  value = "${aws_lb_target_group.admin.name}"
}
