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

output "nat_gateway_ids" {
  description = "NAT gateway IDs used for inspected egress."
  value       = values(aws_nat_gateway.ngw)[*].id
}

output "nat_gateway_eips" {
  description = "The elastic IPs of the nat gateway in the inspection vpc."
  value       = values(aws_eip.ngw)[*].public_ip
}

output "vpc_flow_log_group_name" {
  description = "Name of the CloudWatch log group receiving VPC flow logs, or null when flow_logs_enabled is false."
  value       = try(aws_cloudwatch_log_group.flow_logs[0].name, null)
}

output "ec2_transit_gateway_route_table_id" {
  description = "The id of the ec2 TGW route table"
  value       = aws_ec2_transit_gateway_route_table.tgw.id
}

output "ec2_transit_gateway_vpc_attachment_id" {
  description = "The id of the ec2 tgw attachment to the inspection vpc"
  value       = aws_ec2_transit_gateway_vpc_attachment.tgw_inspection_vpc_attachment.id
}
