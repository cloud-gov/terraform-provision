/* VPC */
output "vpc_id" {
    value = "${aws_vpc.main_vpc.id}"
}

output "vpc_cidr" {
    value = "${var.vpc_cidr}"
}

/* Private network */
output "private_subnet_az1" {
  value = "${aws_subnet.az1_private.id}"
}

output "private_subnet_az2" {
  value = "${aws_subnet.az2_private.id}"
}

output "private_cidr_az1" {
  value = "${aws_subnet.az1_private.cidr_block}"
}

output "private_cidr_az2" {
  value = "${aws_subnet.az2_private.cidr_block}"
}

output "private_route_table_az1" {
  value = "${aws_route_table.az1_private_route_table.id}"
}

output "private_route_table_az2" {
  value = "${aws_route_table.az2_private_route_table.id}"
}

/* Public network */
output "public_subnet_az1" {
  value = "${aws_subnet.az1_public.id}"
}

output "public_subnet_az2" {
  value = "${aws_subnet.az2_public.id}"
}

output "public_cidr_az1" {
  value = "${aws_subnet.az1_public.cidr_block}"
}

output "public_cidr_az2" {
  value = "${aws_subnet.az2_public.cidr_block}"
}

output "public_route_table" {
  value = "${aws_route_table.public_network.id}"
}

output "nat_egress_ip_az1" {
  value = "${join(",", aws_eip.az1_nat_eip.*.public_ip)}"
}

output "nat_egress_ip_az2" {
  value = "${join(",", aws_eip.az2_nat_eip.*.public_ip)}"
}

output "nat_private_ip_az1" {
  value = "${aws_instance.az1_private_nat_2017_09.private_ip}"
}

output "nat_private_ip_az2" {
  value = "${aws_instance.az2_private_nat_2017_09.private_ip}"
}

/* Security Groups */
output "bosh_security_group" {
  value = "${aws_security_group.bosh.id}"
}

output "local_vpc_traffic_security_group" {
    value = "${aws_security_group.local_vpc_traffic.id}"
}

output "web_traffic_security_group" {
  value = "${aws_security_group.web_traffic.id}"
}

output "restricted_web_traffic_security_group" {
  value = "${aws_security_group.restricted_web_traffic.id}"
}

