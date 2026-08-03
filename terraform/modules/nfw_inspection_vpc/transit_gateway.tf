locals {
  create_tgw = var.create_transit_gateway
  tgw_id     = local.create_tgw ? aws_ec2_transit_gateway.this[0].id : var.existing_transit_gateway_id
}

resource "aws_ec2_transit_gateway" "this" {
  count = local.create_tgw ? 1 : 0

  description                     = "${var.name_prefix}-tgw"
  amazon_side_asn                 = var.amazon_side_asn
  auto_accept_shared_attachments  = "disable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  dns_support                     = "enable"

  tags = merge(var.tags, { Name = "${var.name_prefix}-tgw" })
}

# Spokes send everything to the inspection endpoint; inspection sends back to spokes.
resource "aws_ec2_transit_gateway_route_table" "spoke" {
  transit_gateway_id = local.tgw_id
  tags               = merge(var.tags, { Name = "${var.name_prefix}-tgw-rt-spoke" })
}

resource "aws_ec2_transit_gateway_route_table" "inspection" {
  transit_gateway_id = local.tgw_id
  tags               = merge(var.tags, { Name = "${var.name_prefix}-tgw-rt-inspection" })
}
