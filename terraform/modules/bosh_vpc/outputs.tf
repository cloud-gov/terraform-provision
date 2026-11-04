/* VPC */
output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "vpc_cidr" {
  value = var.vpc_cidr
}

/* Private network */
output "private_subnet_az1" {
  value = aws_subnet.az1_private.id
}

output "private_subnet_az2" {
  value = aws_subnet.az2_private.id
}

output "private_cidr_az1" {
  value = aws_subnet.az1_private.cidr_block
}

output "private_cidr_az2" {
  value = aws_subnet.az2_private.cidr_block
}

output "private_route_table_az1" {
  value = aws_route_table.az1_private_route_table.id
}

output "private_route_table_az2" {
  value = aws_route_table.az2_private_route_table.id
}

/* Public network */
output "public_subnet_az1" {
  value = aws_subnet.az1_public.id
}

output "public_subnet_az2" {
  value = aws_subnet.az2_public.id
}

output "public_cidr_az1" {
  value = aws_subnet.az1_public.cidr_block
}

output "public_cidr_az2" {
  value = aws_subnet.az2_public.cidr_block
}

output "public_route_table" {
  value = aws_route_table.public_network.id
}

/*
 * Addresses of this VPC's own NAT gateways.
 */
output "nat_egress_ip_az1" {
  value = join(",", aws_eip.az1_nat_eip.*.public_ip)
}

output "nat_egress_ip_az2" {
  value = join(",", aws_eip.az2_nat_eip.*.public_ip)
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
output "vpc_endpoint_customer_s3_if1_ip" {
  value = data.aws_network_interface.vpce_customer_s3_if1.private_ip
}

output "vpc_endpoint_customer_s3_if2_ip" {
  value = data.aws_network_interface.vpce_customer_s3_if2.private_ip
}

/* DNS for the S3 Private Endpoint */
output "vpc_endpoint_customer_s3_dns" {
  value = aws_vpc_endpoint.customer_s3.dns_entry
}

output "inspection_attached" {
  description = "Whether the spoke side of the inspection VPC attachment exists. True in both phases of a staged cutover, and true whenever inspection_enabled is true. Attached but not enabled means the transit gateway path is built and idle."
  value       = local.inspection_attached
}

output "inspection_enabled" {
  description = "Whether this VPC's private egress is actually routed through the network firewall inspection VPC. False during phase one of a staged cutover even though the attachment exists."
  value       = local.inspection_enabled
}

output "inspection_tgw_subnets" {
  description = "IDs of the transit gateway attachment subnets, or an empty list when the VPC is not attached."
  value       = aws_subnet.tgw[*].id
}

output "inspection_tgw_attachment_id" {
  description = "ID of this VPC's attachment to the inspection VPC's transit gateway, or null when the VPC is not attached."
  value       = one(aws_ec2_transit_gateway_vpc_attachment.main_vpc[*].id)
}

output "inspection_tgw_route_table_id" {
  description = "ID of this VPC's own transit gateway route table, or null when the VPC is not attached."
  value       = one(aws_ec2_transit_gateway_route_table.main_vpc[*].id)
}

output "inspection_nat_egress_ips" {
  description = "Public IPs of the inspection VPC's NAT gateways: the addresses egress traffic from this VPC originates from once inspection_enabled is true, and therefore the addresses external allowlists need. Populated as soon as the VPC is attached, which is deliberate -- these values are needed during phase one, while nat_egress_ip_az1/az2 are still live, so allowlists can be updated before traffic moves rather than after. Empty when the VPC is not attached."
  value       = local.inspection_nat_egress_ips
}
