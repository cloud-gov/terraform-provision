/*
 * Variables required:
 *  stack_description
 *  availability_zones
 *  az2
 *  public_cidrs
 *
 * Resources required:
 *   aws_vpc referenced as 'main_vpc'
 */

resource "aws_subnet" "subnet_public" {
  count  = length(var.availability_zones)

  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.public_cidrs[count.index]

  // Hack: Default to a valid ipv6 cidr to handle empty vpc cidr on initial plan
  ipv6_cidr_block = cidrsubnet(
    aws_vpc.main_vpc.ipv6_cidr_block != "" ? aws_vpc.main_vpc.ipv6_cidr_block : "fd00::/8",
    8,
    0,
  )
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.stack_description} (Public AZ${count.index + 1})"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.stack_description} (Gateway)"
  }
}

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

  tags = {
    Name = "${var.stack_description} (Public Route Table)"
  }
}

resource "aws_route_table_association" "public_rta" {
  count  = length(var.availability_zones)
  subnet_id      = aws_subnet.subnet_public[count.index].id
  route_table_id = aws_route_table.public_network.id
}
