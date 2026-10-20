locals {
  # Flatten spoke -> route table pairs for updating existing route tables.
  spoke_route_tables = merge([
    for k, v in var.spoke_vpcs : {
      for rt in v.route_table_ids :
      "${k}-${rt}" => {
        spoke   = k
        rt_id   = rt
        inspect = v.inspect_egress
      }
    }
  ]...)
}

############################################
# Attach EXISTING spoke VPCs to the TGW
############################################
resource "aws_ec2_transit_gateway_vpc_attachment" "spoke" {
  for_each = var.spoke_vpcs

  transit_gateway_id                              = local.tgw_id
  vpc_id                                          = each.value.vpc_id
  subnet_ids                                      = each.value.tgw_attachment_subnet_ids
  appliance_mode_support                          = "disable"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = merge(var.tags, { Name = "${var.name_prefix}-spoke-${each.key}-attach" })
}

# Associate each spoke attachment with the SPOKE TGW route table.
resource "aws_ec2_transit_gateway_route_table_association" "spoke" {
  for_each = var.spoke_vpcs

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke[each.key].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke.id
}

# Propagate spoke CIDRs into the INSPECTION route table so the inspection VPC
# (post-firewall) knows how to route back to each spoke.
resource "aws_ec2_transit_gateway_route_table_propagation" "spoke_to_inspection" {
  for_each = var.spoke_vpcs

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke[each.key].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection.id
}

############################################
# TGW routing logic
#
# SPOKE route table: default route (0.0.0.0/0) -> inspection attachment.
#   This forces ALL spoke egress AND east-west traffic through the firewall.
#
# INSPECTION route table: spoke CIDRs are propagated (above), so returning
#   traffic reaches the correct spoke. Its own default route is not needed
#   because egress leaves via the inspection VPC's NAT/IGW, not the TGW.
############################################

# Send everything from spokes to the inspection VPC for inspection.
resource "aws_ec2_transit_gateway_route" "spoke_default_to_inspection" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inspection.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke.id
}

############################################
# Modify EXISTING spoke VPC route tables
#
# For egress + east-west inspection, point the default route at the TGW.
# WARNING: this REPLACES any existing 0.0.0.0/0 route in the target
# route tables (e.g., an existing NAT/IGW default route).
############################################
resource "aws_route" "spoke_default_to_tgw" {
  for_each = {
    for k, v in local.spoke_route_tables : k => v
    if v.inspect
  }

  route_table_id         = each.value.rt_id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = local.tgw_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.spoke]
}
