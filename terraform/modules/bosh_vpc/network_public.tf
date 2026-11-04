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

/*
 * The public route table keeps its default route on the internet gateway even
 * when inspection is enabled.
 */
resource "aws_route_table" "public_network" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
  }

  # Internal destinations reached through the inspection VPC. Empty, and so a
  # no-op, unless inspection is enabled and inspection_internal_cidrs is set.
  dynamic "route" {
    for_each = local.inspection_enabled ? toset(var.inspection_internal_cidrs) : toset([])
    content {
      cidr_block         = route.value
      transit_gateway_id = local.inspection_transit_gateway_id
    }
  }

  tags = {
    Name = "${var.stack_description} (Public Route Table)"
  }

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.main_vpc,
    aws_ec2_transit_gateway_route_table_association.main_vpc,
    aws_ec2_transit_gateway_route.main_vpc_egress_to_inspection,
    aws_ec2_transit_gateway_route_table_propagation.main_vpc_to_inspection,
  ]
}

resource "aws_route_table_association" "az1_public_rta" {
  subnet_id      = aws_subnet.az1_public.id
  route_table_id = aws_route_table.public_network.id
}

resource "aws_route_table_association" "az2_public_rta" {
  subnet_id      = aws_subnet.az2_public.id
  route_table_id = aws_route_table.public_network.id
}
