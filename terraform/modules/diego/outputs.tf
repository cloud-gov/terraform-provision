
/* Diego Proxy ELB */

output "diego_elb_name" {
  value = "${aws_elb.diego_elb_main.name}"
}

output "diego_elb_dns_name" {
  value = "${aws_elb.diego_elb_main.dns_name}"
}

/* Diego subnets */
output "diego_services_subnet_az1" {
  value = "${aws_subnet.diego_az1_services.id}"
}
output "diego_services_subnet_az2" {
  value = "${aws_subnet.diego_az2_services.id}"
}

