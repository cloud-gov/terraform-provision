/*
 * Variables required:
 *   stack_description
 *   rds_subnet_az1
 *   rds_subnet_az2
 */

resource "aws_db_subnet_group" "rds" {
  name = "rds"
  description = "${var.stack_description} (Multi-AZ Subnet Group)"
  subnet_ids = ["${var.rds_subnet_az1}", "${var.rds_subnet_az2}"]
}
