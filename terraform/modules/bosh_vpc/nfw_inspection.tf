locals {
  availability_zones = [var.az1, var.az2]
}

data "aws_ec2_transit_gateway" "tgw" {
  count = var.egress_traffic_through_inspection_vpc ? 1 : 0
  id    = var.transit_gateway_id
}

resource "aws_subnet" "tgw" {
  count                   = var.egress_traffic_through_inspection_vpc ? 2 : 0
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = tgw_cidr_blocks[count.index]
  availability_zone       = local.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.stack_description}-tgw-subnet-${local.availability_zones[count.index]}"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "main-vpc" {
  count                                           = var.egress_traffic_through_inspection_vpc ? 1 : 0
  subnet_ids                                      = aws_subnet.spoke_b_tgw[*].id
  transit_gateway_id                              = data.aws_ec2_transit_gateway.tgw.id
  vpc_id                                          = aws_vpc.main_vpc.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = {
    Name = "${var.stack_description}-nfw-inspection-vpc-attachment"
  }
}
