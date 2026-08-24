/*
 * Variables required:
 *  stack_description
 *  az1
 *  az2
 *  public_cidr_1
 *  public_cidr_2
 *
 * Resources required:
 *   aws_vpc referenced as 'main_vpc'
 */

resource "aws_subnet" "az1_public" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.public_cidr_1

  // Hack: Default to a valid ipv6 cidr to handle empty vpc cidr on initial plan
  ipv6_cidr_block = cidrsubnet(
    aws_vpc.main_vpc.ipv6_cidr_block != "" ? aws_vpc.main_vpc.ipv6_cidr_block : "fd00::/8",
    8,
    0,
  )
  availability_zone = var.az1

  tags = {
    Name = "${var.stack_description} (Public AZ1)"
  }
}

resource "aws_subnet" "az2_public" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.public_cidr_2

  // Hack: Default to a valid ipv6 cidr to handle empty vpc cidr on initial plan
  ipv6_cidr_block = cidrsubnet(
    aws_vpc.main_vpc.ipv6_cidr_block != "" ? aws_vpc.main_vpc.ipv6_cidr_block : "fd00::/8",
    8,
    1,
  )
  availability_zone = var.az2

  tags = {
    Name = "${var.stack_description} (Public AZ2)"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.stack_description} (Gateway)"
  }
}

# Do not create this route table when the nfw inspection vpc is in use
resource "aws_route_table" "public_network" {
  count  = var.egress_traffic_through_inspection_vpc ? 0 : 1
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.stack_description} (Public Route Table)"
  }
}

resource "aws_route_table_association" "az1_public_rta" {
  count          = var.egress_traffic_through_inspection_vpc ? 0 : 1
  subnet_id      = aws_subnet.az1_public.id
  route_table_id = aws_route_table.public_network[0].id
}

resource "aws_route_table_association" "az2_public_rta" {
  count          = var.egress_traffic_through_inspection_vpc ? 0 : 1
  subnet_id      = aws_subnet.az2_public.id
  route_table_id = aws_route_table.public_network[0].id
}

# Create when nfw inspection vpc is in use
# For egress + east-west inspection, point the default route at the TGW.
resource "aws_route_table" "public_network_with_nfw_inspection_vpc" {
  count  = var.egress_traffic_through_inspection_vpc ? 1 : 0
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "${var.stack_description} (Public Route Table w/ NFW Inspection VPC)"
  }
}

resource "aws_route" "public_network_egress_through_nfw_inspection_vpc" {
  count                  = var.egress_traffic_through_inspection_vpc ? 1 : 0
  route_table_id         = aws_route_table.public_network_with_nfw_inspection_vpc[0].id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = data.terraform_remote_state.firewall-inspection-vpc.outputs.transit_gateway_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.main_vpc]
}

resource "aws_route_table_association" "public_network_with_nfw_inspection_vpc_az1" {
  count          = var.egress_traffic_through_inspection_vpc ? 1 : 0
  subnet_id      = aws_subnet.az1_public.id
  route_table_id = aws_route_table.public_network_with_nfw_inspection_vpc[0].id
}

resource "aws_route_table_association" "public_network_with_nfw_inspection_vpc_az2" {
  count          = var.egress_traffic_through_inspection_vpc ? 1 : 0
  subnet_id      = aws_subnet.az2_public.id
  route_table_id = aws_route_table.public_network_with_nfw_inspection_vpc[0].id
}
