/*
 * Optional centralized egress through the network firewall inspection VPC.
 */

locals {
  inspection_attached = var.attach_to_inspection_vpc || var.egress_traffic_through_inspection_vpc

  inspection_enabled = var.egress_traffic_through_inspection_vpc

  availability_zones = [var.az1, var.az2]

  tgw_subnet_cidrs_padded = length(var.tgw_subnet_cidrs) == 2 ? var.tgw_subnet_cidrs : ["", ""]

  inspection_transit_gateway_id = one(
    data.terraform_remote_state.firewall_inspection_vpc[*].outputs.transit_gateway_id
  )

  inspection_tgw_route_table_id = one(
    data.terraform_remote_state.firewall_inspection_vpc[*].outputs.ec2_transit_gateway_route_table_id
  )

  inspection_tgw_vpc_attachment_id = one(
    data.terraform_remote_state.firewall_inspection_vpc[*].outputs.ec2_transit_gateway_vpc_attachment_id
  )

  inspection_nat_egress_ips = flatten(
    data.terraform_remote_state.firewall_inspection_vpc[*].outputs.nat_gateway_eips
  )
}

data "terraform_remote_state" "firewall_inspection_vpc" {
  count   = local.inspection_attached ? 1 : 0
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket
    key    = var.remote_state_key

    region = var.aws_default_region
  }

  # remote_state_bucket has no working default
  lifecycle {
    precondition {
      condition     = var.remote_state_bucket != ""
      error_message = "This VPC is attached to the inspection VPC (attach_to_inspection_vpc or egress_traffic_through_inspection_vpc is true), so remote_state_bucket must name the S3 bucket holding the firewall-inspection-vpc stack's Terraform state."
    }

    precondition {
      condition     = var.remote_state_key != ""
      error_message = "remote_state_key must not be empty; it is the state key of the firewall-inspection-vpc stack within remote_state_bucket."
    }
  }
}

# Subnets for the transit gateway's ENIs, one per AZ.
resource "aws_subnet" "tgw" {
  count                   = local.inspection_attached ? 2 : 0
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = local.tgw_subnet_cidrs_padded[count.index]
  availability_zone       = local.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.stack_description} (TGW AZ${count.index + 1})"
  }

  lifecycle {
    precondition {
      condition     = length(var.tgw_subnet_cidrs) == 2
      error_message = "This VPC is attached to the inspection VPC (attach_to_inspection_vpc or egress_traffic_through_inspection_vpc is true), so tgw_subnet_cidrs must contain exactly two CIDRs (one per AZ, ordered [az1, az2]) inside vpc_cidr (${var.vpc_cidr}), not overlapping any other subnet in this VPC. It currently has ${length(var.tgw_subnet_cidrs)} entries."
    }
  }
}

# Dedicated VPC route table for the TGW subnets.
resource "aws_route_table" "tgw" {
  count  = local.inspection_attached ? 1 : 0
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.stack_description} (TGW Subnet Route Table)"
  }
}

resource "aws_route_table_association" "tgw" {
  count          = local.inspection_attached ? 2 : 0
  subnet_id      = aws_subnet.tgw[count.index].id
  route_table_id = aws_route_table.tgw[0].id
}

# Spoke-side attachment to the inspection VPC's transit gateway.
#
# appliance_mode_support is deliberately not set here. Appliance mode belongs on
# the attachment that fronts the stateful appliance -- the inspection VPC's own
# attachment, which enables it -- and setting it on a spoke does not affect flow
# symmetry through the firewall.
resource "aws_ec2_transit_gateway_vpc_attachment" "main_vpc" {
  count                                           = local.inspection_attached ? 1 : 0
  transit_gateway_id                              = local.inspection_transit_gateway_id
  vpc_id                                          = aws_vpc.main_vpc.id
  subnet_ids                                      = aws_subnet.tgw[*].id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = {
    Name = "${var.stack_description} (Inspection VPC Attachment)"
  }
}

# This spoke's own TGW route table, separate from the inspection VPC's.
resource "aws_ec2_transit_gateway_route_table" "main_vpc" {
  count              = local.inspection_attached ? 1 : 0
  transit_gateway_id = local.inspection_transit_gateway_id

  tags = {
    Name = "${var.stack_description} (TGW Route Table)"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "main_vpc" {
  count                          = local.inspection_attached ? 1 : 0
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.main_vpc[0].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main_vpc[0].id
}

# Everything this VPC sends over the TGW goes to the inspection VPC. This is the
# route that actually forces traffic through the firewall; without it the
# attachment exists but carries nothing.
resource "aws_ec2_transit_gateway_route" "main_vpc_egress_to_inspection" {
  count                          = local.inspection_attached ? 1 : 0
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = local.inspection_tgw_vpc_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main_vpc[0].id
}

# Return path. Propagating this attachment into the inspection VPC's TGW route
# table is what teaches the inspection side how to reach this VPC's CIDRs once
# the firewall has passed a flow.
#
# This cannot be declared from the inspection VPC side instead, which would be
# the obvious way to have it exist before the spoke attaches. The propagation
# requires this attachment's id, which AWS generates on creation, and that id
# lives in this stack's state.
resource "aws_ec2_transit_gateway_route_table_propagation" "main_vpc_to_inspection" {
  count                          = local.inspection_attached ? 1 : 0
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.main_vpc[0].id
  transit_gateway_route_table_id = local.inspection_tgw_route_table_id
}
