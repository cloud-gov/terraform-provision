output "transit_gateway_id" {
  description = "ID of the Transit Gateway (created or existing)."
  value       = local.tgw_id
}

output "inspection_vpc_id" {
  description = "ID of the inspection VPC."
  value       = aws_vpc.inspection.id
}

output "firewall_arn" {
  description = "ARN of the AWS Network Firewall."
  value       = aws_networkfirewall_firewall.this.arn
}

output "firewall_endpoints" {
  description = "Map of AZ -> firewall VPC endpoint ID."
  value       = local.fw_endpoints
}

output "tgw_route_table_spoke_id" {
  description = "TGW route table ID for spokes."
  value       = aws_ec2_transit_gateway_route_table.spoke.id
}

output "tgw_route_table_inspection_id" {
  description = "TGW route table ID for the inspection VPC."
  value       = aws_ec2_transit_gateway_route_table.inspection.id
}

output "spoke_attachment_ids" {
  description = "Map of spoke logical name -> TGW attachment ID."
  value       = { for k, v in aws_ec2_transit_gateway_vpc_attachment.spoke : k => v.id }
}

output "nat_gateway_ids" {
  description = "NAT gateway IDs used for inspected egress."
  value       = aws_nat_gateway.this[*].id
}
