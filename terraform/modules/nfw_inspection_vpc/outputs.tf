output "transit_gateway_id" {
  description = "ID of the Transit Gateway."
  value       = aws_ec2_transit_gateway.tgw.id
}

output "inspection_vpc_id" {
  description = "ID of the inspection VPC."
  value       = aws_vpc.inspection.id
}

output "firewall_arn" {
  description = "ARN of the AWS Network Firewall."
  value       = aws_networkfirewall_firewall.firewall.arn
}

output "firewall_endpoints" {
  description = "Map of AZ -> firewall VPC endpoint ID."
  value       = local.fw_endpoints
}

# output "tgw_route_table_spoke_id" {
#   description = "TGW route table ID for spokes."
#   value       = aws_ec2_transit_gateway_route_table.spoke.id
# }

output "tgw_route_table_inspection_id" {
  description = "TGW route table ID for the inspection VPC."
  value       = aws_ec2_transit_gateway_route_table.tgw.id
}

# output "spoke_attachment_ids" {
#   description = "Map of spoke logical name -> TGW attachment ID."
#   value       = { for k, v in aws_ec2_transit_gateway_vpc_attachment.spoke : k => v.id }
# }

output "nat_gateway_ids" {
  description = "NAT gateway IDs used for inspected egress."
  value       = aws_nat_gateway.ngw[*].id
}

output "nat_gateway_eips" {
  description = "The elastic IPs of the nat gateway in the inspection vpc."
  value       = aws_eip.ngw
}

output "ec2_transit_gateway_route_table_id" {
  description = "The id of the ec2 TGW route table"
  value       = aws_ec2_transit_gateway_route_table.tgw.id
}

output "ec2_transit_gateway_vpc_attachment_id" {
  description = "The id of the ec2 tgw attachment to the inspection vpc"
  value       = aws_ec2_transit_gateway_vpc_attachment.tgw-inspection-vpc-attachment.id
}
