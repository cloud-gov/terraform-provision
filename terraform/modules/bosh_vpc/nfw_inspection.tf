locals {
  availability_zones = [var.az1, var.az2]
}

data "terraform_remote_state" "firewall-inspection-vpc" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket
    key    = "firewall-inspection-vpc/terraform.tfstate"
  }
}

# Subnet in the main_vpc to attach the transit gateway to
resource "aws_subnet" "tgw" {
  count                   = var.egress_traffic_through_inspection_vpc ? 2 : 0
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.tgw_cidr_blocks[count.index]
  availability_zone       = local.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.stack_description}-tgw-subnet-${local.availability_zones[count.index]}"
  }
}

# TGW attachment to the main_vpc via the subnet above
resource "aws_ec2_transit_gateway_vpc_attachment" "main_vpc" {
  count                                           = var.egress_traffic_through_inspection_vpc ? 1 : 0
  subnet_ids                                      = aws_subnet.tgw[*].id
  transit_gateway_id                              = data.terraform_remote_state.firewall-inspection-vpc.outputs.transit_gateway_id
  vpc_id                                          = aws_vpc.main_vpc.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = {
    Name = "${var.stack_description}-nfw-inspection-vpc-attachment"
  }
}

# TGW routing in the main_vpc
resource "aws_ec2_transit_gateway_route_table" "main_vpc" {
  count              = var.egress_traffic_through_inspection_vpc ? 1 : 0
  transit_gateway_id = data.terraform_remote_state.firewall-inspection-vpc.outputs.transit_gateway_id
  tags = {
    Name = "${var.stack_description}-tgw-route-table"
  }
}

# Associate the main_vpc attachment with the main_vpc tgw route table.
resource "aws_ec2_transit_gateway_route_table_association" "main_vpc" {
  count                          = var.egress_traffic_through_inspection_vpc ? 1 : 0
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.main_vpc[0].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main_vpc[0].id
}

# Propagate main_vpc CIDRs into the inspection route table so the inspection VPC
# (post-firewall) knows how to route back to the main_vpc.
resource "aws_ec2_transit_gateway_route_table_propagation" "main_vpc_to_inspection" {
  count                          = var.egress_traffic_through_inspection_vpc ? 1 : 0
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.main_vpc[0].id
  transit_gateway_route_table_id = data.terraform_remote_state.firewall-inspection-vpc.outputs.ec2_transit_gateway_route_table_id
}


# main_vpc tgw route table: egress route (0.0.0.0/0) -> inspection attachment.
# This forces ALL main_vpc egress AND east-west traffic through the firewall.
#
# Note on inspection tgw route table: main_vpc CIDRs are propagated above
# (aws_ec2_transit_gateway_route_table_propagation.main_vpc_to_inspection),
# so returning traffic reaches the correct vpc. Its own default route is not needed because egress leaves via the inspection VPC's NAT/IGW.
resource "aws_ec2_transit_gateway_route" "main_vpc_egress_to_inspection" {
  count                          = var.egress_traffic_through_inspection_vpc ? 1 : 0
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = data.terraform_remote_state.firewall-inspection-vpc.outputs.ec2_transit_gateway_vpc_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main_vpc[0].id
}
