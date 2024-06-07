/* VPC */
output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "vpc_cidr" {
  value = var.vpc_cidr
}

/* Private network */
output "private_subnet_ids" {
  value = aws_subnet.subnet_private[*].id
}

output "private_cidrs" {
  value = aws_subnet.subnet_private[*].cidr_block
}

output "private_route_table_ids" {
  value = aws_route_table.private_route_table[*].id
}

/* Public network */

output "public_subnet_ids" {
  value = aws_subnet.subnet_public[*].id
}

output "public_cidrs" {
  value = aws_subnet.subnet_public[*].cidr_block
}

output "public_route_table_ids" {
  value = aws_route_table.public_network[*].id
}

output "nat_egress_ips" {
  value = aws_eip.private_nat_eip[*].*.public_ip
}

/* Security Groups */
output "bosh_security_group" {
  value = aws_security_group.bosh.id
}

output "local_vpc_traffic_security_group" {
  value = aws_security_group.local_vpc_traffic.id
}

output "web_traffic_security_group" {
  value = aws_security_group.web_traffic.id
}

output "restricted_web_traffic_security_group" {
  value = aws_security_group.restricted_web_traffic.id
}

output "default_key_name" {
  value = aws_key_pair.bosh.key_name
}

/* S3 Private Endpoint for region*/
output "vpc_endpoint_customer_s3_if_ips" {
  value = data.aws_network_interface.vpce_customer_s3_if[*].private_ip
}


/* DNS for the S3 Private Endpoint */
output "vpc_endpoint_customer_s3_dns" {
  value = aws_vpc_endpoint.customer_s3.dns_entry
}