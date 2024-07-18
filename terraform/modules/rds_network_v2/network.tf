/*
 * Variables required:
 *   stack_description
 *   vpc_id
 *   rds_private_cidrs
 *   availability_zones
 */

resource "aws_subnet" "subnet_rds" {
  count = length(var.availability_zones)

  vpc_id            = var.vpc_id
  cidr_block        = var.rds_private_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.stack_description} (RDS AZ${count.index + 1})"
  }
}

resource "aws_db_subnet_group" "rds" {
  name        = var.stack_description
  description = "${var.stack_description} (Multi-AZ Subnet Group)"
  subnet_ids  = aws_subnet.subnet_rds[*].id
}

resource "aws_route_table_association" "rds_rta" {
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.subnet_rds[count.index].id
  route_table_id = var.route_table_ids[count.index]
}
