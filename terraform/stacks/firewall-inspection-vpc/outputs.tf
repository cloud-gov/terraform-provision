output "transit_gateway_id" {
  description = "ID of the Transit Gateway."
  value       = module.nfw_inspection_vpc.transit_gateway_id
}

output "inspection_vpc_id" {
  description = "ID of the inspection VPC."
  value       = module.nfw_inspection_vpc.inspection_vpc_id
}

output "tgw_route_table_inspection_id" {
  description = "TGW route table ID for the inspection VPC."
  value       = module.nfw_inspection_vpc.tgw_route_table_inspection_id
}
