output "shibboleth_lb_target_group" {
  value = "${aws_lb_target_group.shibboleth.name}"
}
