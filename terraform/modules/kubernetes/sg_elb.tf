resource "aws_security_group" "kubernetes_elb" {
  description = "Allow access to incoming kubernetes traffic"
  vpc_id = "${var.vpc_id}"

  tags = {
    Name = "${var.stack_description} - Kubernetes ELB"
  }
}

resource "aws_security_group_rule" "kubernetes_inbound_api" {
  type = "ingress"
  from_port = 6443
  to_port = 6443
  protocol = "tcp"
  cidr_blocks = ["${var.vpc_cidr}"]
  security_group_id = "${aws_security_group.kubernetes_elb.id}"
}

resource "aws_security_group_rule" "kubernetes_inbound_custom" {
  type = "ingress"
  from_port = 6443
  to_port = 6443
  protocol = "tcp"
  source_security_group_id = "${var.target_monitoring_security_group}"
  security_group_id = "${aws_security_group.kubernetes_elb.id}"
}

resource "aws_security_group_rule" "kubernetes_inbound_from_concourse" {
  type = "ingress"
  from_port = 6443
  to_port = 6443
  protocol = "tcp"
  source_security_group_id = "${var.target_concourse_security_group}"
  security_group_id = "${aws_security_group.kubernetes_elb.id}"
}

resource "aws_security_group_rule" "kubernetes_outbound" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = -1
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.kubernetes_elb.id}"
}
