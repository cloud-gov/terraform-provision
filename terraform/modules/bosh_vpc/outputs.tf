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
  value = var.create_network_firewall ? aws_route_table.public_network_with_firewall[0].id : aws_route_table.public_network[0].id
}

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

/* Network Firewall */
output "network_firewall_id" {
  value       = try(aws_networkfirewall_firewall.main[0].id, null)
  description = "ID of the AWS Network Firewall (null when not created)."
}

output "network_firewall_arn" {
  value       = try(aws_networkfirewall_firewall.main[0].arn, null)
  description = "ARN of the AWS Network Firewall."
}

output "network_firewall_policy_arn" {
  value       = try(aws_networkfirewall_firewall_policy.main[0].arn, null)
  description = "ARN of the firewall policy."
}

output "firewall_subnet_az1" {
  value       = try(aws_subnet.az1_firewall[0].id, null)
  description = "AZ1 firewall subnet ID."
}

output "firewall_subnet_az2" {
  value       = try(aws_subnet.az2_firewall[0].id, null)
  description = "AZ2 firewall subnet ID."
}

output "nat_subnet_az1" {
  value       = try(aws_subnet.az1_nat[0].id, null)
  description = "AZ1 dedicated NAT subnet ID (null when firewall disabled)."
}

output "nat_subnet_az2" {
  value       = try(aws_subnet.az2_nat[0].id, null)
  description = "AZ2 dedicated NAT subnet ID (null when firewall disabled)."
}

output "firewall_route_table_az1" {
  value       = try(aws_route_table.az1_firewall_route_table[0].id, null)
  description = "AZ1 firewall subnet route table ID."
}

output "firewall_route_table_az2" {
  value       = try(aws_route_table.az2_firewall_route_table[0].id, null)
  description = "AZ2 firewall subnet route table ID."
}

output "nat_route_table_az1" {
  value       = try(aws_route_table.az1_nat_route_table[0].id, null)
  description = "AZ1 NAT subnet route table ID."
}

output "nat_route_table_az2" {
  value       = try(aws_route_table.az2_nat_route_table[0].id, null)
  description = "AZ2 NAT subnet route table ID."
}

output "firewall_igw_ingress_route_table" {
  value       = try(aws_route_table.firewall_igw_ingress[0].id, null)
  description = "IGW edge route table ID used for ingress inspection."
}
