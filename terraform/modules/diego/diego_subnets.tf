
/*
 * Variables required:
 *  stack_description
 *  az1
 *  az2
 *  diego_cidr_1
 *  diego_cidr_2
 *  vpc_id
 *  private_route_table_az1
 *  private_route_table_az2
 *
 */

resource "aws_subnet" "diego_az1_services" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "${var.diego_cidr_1}"
  availability_zone = "${var.az1}"


  tags =  {
    Name = "${var.stack_description} (Diego Services AZ1)"
  }
}

resource "aws_subnet" "diego_az2_services" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "${var.diego_cidr_2}"
  availability_zone = "${var.az2}"

  tags =  {
    Name = "${var.stack_description} (Diego Services AZ2)"
  }
}

resource "aws_cloudwatch_log_group" "diego_flow_logs" {
  name = "${var.stack_description}-diego-flow-logs"
}

resource "aws_flow_log" "diego_az1_flow_log" {
  log_group_name = "${aws_cloudwatch_log_group.diego_flow_logs.name}"
  iam_role_arn = "${var.flow_log_role_arn}"
  subnet_id = "${aws_subnet.diego_az1_services.id}"
  traffic_type = "ALL"
}

resource "aws_flow_log" "diego_az2_flow_log" {
  log_group_name = "${aws_cloudwatch_log_group.diego_flow_logs.name}"
  iam_role_arn = "${var.flow_log_role_arn}"
  subnet_id = "${aws_subnet.diego_az2_services.id}"
  traffic_type = "ALL"
}

resource "aws_route_table_association" "az1_services_rta" {
  subnet_id = "${aws_subnet.diego_az1_services.id}"
  route_table_id = "${var.private_route_table_az1}"
}

resource "aws_route_table_association" "az2_services_rta" {
  subnet_id = "${aws_subnet.diego_az2_services.id}"
  route_table_id = "${var.private_route_table_az2}"
}
