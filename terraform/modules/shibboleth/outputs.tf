
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
