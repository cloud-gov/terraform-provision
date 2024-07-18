resource "aws_subnet" "az1_elasticsearch" {
  vpc_id            = var.vpc_id
  cidr_block        = var.elasticsearch_private_cidr_1
  availability_zone = var.az1

  tags = {
    Name = "${var.stack_description} (elasticsearch Broker 1 - AZ1)"
  }
}

resource "aws_subnet" "az2_elasticsearch" {
  vpc_id            = var.vpc_id
  cidr_block        = var.elasticsearch_private_cidr_2
  availability_zone = var.az2

  tags = {
    Name = "${var.stack_description} (elasticsearch Broker 2 - AZ2)"
  }
}

# This is actually AZ 1, not a third AZ. We can't rename the resource without
# destroying the subnet though.
resource "aws_subnet" "az3_elasticsearch" {
  vpc_id            = var.vpc_id
  cidr_block        = var.elasticsearch_private_cidr_3
  availability_zone = var.az1

  tags = {
    Name = "${var.stack_description} (elasticsearch Broker 3 - AZ1)"
  }
}

# This is actually AZ 2, not a fourth AZ. We can't rename the resource without
# destroying the subnet though.
resource "aws_subnet" "az4_elasticsearch" {
  vpc_id            = var.vpc_id
  cidr_block        = var.elasticsearch_private_cidr_4
  availability_zone = var.az2

  tags = {
    Name = "${var.stack_description} (elasticsearch Broker 4 - AZ2)"
  }
}

resource "aws_route_table_association" "az1_elasticsearch_rta" {
  subnet_id      = aws_subnet.az1_elasticsearch.id
  route_table_id = var.az1_route_table
}

resource "aws_route_table_association" "az2_elasticsearch_rta" {
  subnet_id      = aws_subnet.az2_elasticsearch.id
  route_table_id = var.az2_route_table
}

resource "aws_route_table_association" "az3_elasticsearch_rta" {
  subnet_id      = aws_subnet.az3_elasticsearch.id
  route_table_id = var.az1_route_table
}

resource "aws_route_table_association" "az4_elasticsearch_rta" {
  subnet_id      = aws_subnet.az4_elasticsearch.id
  route_table_id = var.az2_route_table
}

