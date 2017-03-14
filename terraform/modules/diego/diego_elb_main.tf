/*
 * Variables required:
 *   stack_description
 *   elb_subnets
 *
 */

resource "aws_security_group" "diego-elb-sg" {
  name = "${var.stack_description}-diego-elb-sg"
  description = "ELB Security Group for Diego Proxy"

  vpc_id = "${var.vpc_id}"

  # HTTP access from anywhere
  ingress {
    from_port = 2222
    to_port = 2222
    protocol = "tcp"
    cidr_blocks = ["${split(",", var.ingress_cidrs)}"]
  }

  # outbound internet access
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_elb" "diego_elb_main" {
  name = "${var.stack_description}-diego-proxy"
  subnets = ["${split(",", var.elb_subnets)}"]
  security_groups = ["${aws_security_group.diego-elb-sg.id}"]

  listener {
    lb_port = 2222
    lb_protocol = "TCP"
    instance_port = 2222
    instance_protocol = "TCP"
  }

  health_check {
    healthy_threshold = 10
    interval = 30
    target = "TCP:2222"
    timeout = 5
    unhealthy_threshold = 2
  }

  tags {
    Name = "${var.stack_description}-Diego-Proxy-ELB"
  }
}
