/* shibboleth Proxy ELB */

output "shibboleth_elb_name" {
  value = "${aws_elb.shibboleth_elb_main.name}"
}

output "shibboleth_elb_dns_name" {
  value = "${aws_elb.shibboleth_elb_main.dns_name}"
}

output "shibboleth_elb_zone_id" {
  value = "${aws_elb.shibboleth_elb_main.zone_id}"
}

/* shibboleth Proxy LB */

output "shibboleth_lb_name" {
  value = "${aws_lb.shibboleth_lb.name}"
}

output "shibboleth_lb_dns_name" {
  value = "${aws_lb.shibboleth_lb.dns_name}"
}

output "shibboleth_lb_target_group" {
  value = "${aws_lb_target_group.shibboleth_target.name}"
}
