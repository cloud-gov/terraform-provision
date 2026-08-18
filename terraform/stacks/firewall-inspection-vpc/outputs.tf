output "transit_gateway_id" {
  description = "ID of the Transit Gateway."
  value       = aws_ec2_transit_gateway.tgw.id
}

output "inspection_vpc_id" {
  description = "ID of the inspection VPC."
  value       = aws_vpc.inspection.id
}

output "tgw_route_table_inspection_id" {
  description = "TGW route table ID for the inspection VPC."
  value       = aws_ec2_transit_gateway_route_table.tgw.id
}
