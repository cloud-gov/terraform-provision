
/* Diego Proxy ELB */

output "elb_diego_main_name" {
  value = "${aws_elb.diego_elb_main.name}"
}

output "elb_diego_main_dns_name" {
  value = "${aws_elb.diego_elb_main.dns_name}"
}

/* Services network */
output "services_subnet_az1" {
  value = "${aws_subnet.diego_az1_services.id}"
}
output "services_subnet_az2" {
  value = "${aws_subnet.diego_az2_services.id}"
}

