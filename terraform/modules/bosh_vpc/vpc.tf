/*
 * Variables required:
 *  stack_description
 *  vpc_cidr
 */

resource "aws_vpc" "main_vpc" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_support = true
  enable_dns_hostnames = true
  assign_generated_ipv6_cidr_block = true

  tags {
    Name = "${var.stack_description}"
  }

}

module "flow_logs" {
  source = "github.com/GSA/terraform-vpc-flow-log"

  vpc_id = "${aws_vpc.main_vpc.id}"
  prefix = "${var.stack_description}"
  log_group_name = "${var.stack_description}-flow-log-group"
}
