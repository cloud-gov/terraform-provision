resource "aws_subnet" "az1_elasticache" {
  vpc_id            = var.vpc_id
  cidr_block        = var.elasticache_private_cidr_1
  availability_zone = var.az1

  tags = {
    Name = "${var.stack_description} (Elasticache Broker AZ1)"
  }
}

resource "aws_subnet" "az2_elasticache" {
  vpc_id            = var.vpc_id
  cidr_block        = var.elasticache_private_cidr_2
  availability_zone = var.az2

  tags = {
    Name = "${var.stack_description} (Elasticache Broker AZ2)"
  }
}

resource "aws_elasticache_subnet_group" "elasticache" {
  name        = var.stack_description
  description = "${var.stack_description} (Multi-AZ Subnet Group)"
  subnet_ids  = [aws_subnet.az1_elasticache.id, aws_subnet.az2_elasticache.id]
}

resource "aws_route_table_association" "az1_elasticache_rta" {
  subnet_id      = aws_subnet.az1_elasticache.id
  route_table_id = var.az1_route_table
}

resource "aws_route_table_association" "az2_elasticache_rta" {
  subnet_id      = aws_subnet.az2_elasticache.id
  route_table_id = var.az2_route_table
}
