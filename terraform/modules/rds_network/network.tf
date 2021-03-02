/*
 * Variables required:
 *   stack_description
 *   vpc_id
 *   rds_private_cidr1
 *   rds_private_cidr2
 *   az1
 *   az2
 */

resource "aws_subnet" "az1_rds" {
  vpc_id            = var.vpc_id
  cidr_block        = var.rds_private_cidr_1
  availability_zone = var.az1

  tags = {
    Name = "${var.stack_description} (RDS AZ1)"
  }
}

resource "aws_subnet" "az2_rds" {
  vpc_id            = var.vpc_id
  cidr_block        = var.rds_private_cidr_2
  availability_zone = var.az2

  tags = {
    Name = "${var.stack_description} (RDS AZ2)"
  }
}

resource "aws_db_subnet_group" "rds" {
  name        = var.stack_description
  description = "${var.stack_description} (Multi-AZ Subnet Group)"
  subnet_ids  = [aws_subnet.az1_rds.id, aws_subnet.az2_rds.id]
}

resource "aws_route_table_association" "az1_rds_rta" {
  subnet_id      = aws_subnet.az1_rds.id
  route_table_id = var.az1_route_table
}

resource "aws_route_table_association" "az2_rds_rta" {
  subnet_id      = aws_subnet.az2_rds.id
  route_table_id = var.az2_route_table
}

