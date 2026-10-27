resource "aws_ec2_transit_gateway" "tgw" {
  description                     = "${var.name_prefix}-tgw"
  auto_accept_shared_attachments  = "disable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  dns_support                     = "enable"

  tags = merge(var.tags, { Name = "${var.name_prefix}-tgw" })
}

# Attachment - Spoke VPC attachment is in bosh_vpc module
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_inspection_vpc_attachment" {
  transit_gateway_id                              = aws_ec2_transit_gateway.tgw.id
  vpc_id                                          = aws_vpc.inspection.id
  subnet_ids                                      = values(aws_subnet.tgw)[*].id
  appliance_mode_support                          = "enable"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags                                            = merge(var.tags, { Name = "${var.name_prefix}-tgw-inspection-vpc-attachment" })
}

# Route Table - Spoke route table is in the bosh_vpc module
resource "aws_ec2_transit_gateway_route_table" "tgw" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  tags               = merge(var.tags, { Name = "${var.name_prefix}-tgw-rt" })
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_inspection_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw.id
}
