resource "aws_security_group" "kubernetes" {
  description = "Allow access to incoming kubernetes traffic"
  vpc_id = "${var.vpc_id}"

  tags =  {
    Name = "${var.stack_description} - Incoming Kubernetes Traffic"
  }
}

resource "aws_security_group_rule" "self_reference" {
  type = "ingress"
  self = true
  from_port = 0
  to_port = 0
  protocol = -1
  security_group_id = "${aws_security_group.kubernetes.id}"
}

resource "aws_security_group_rule" "kubernetes_inbound_api" {
  type = "ingress"
  from_port = 6443
  to_port = 6443
  protocol = "tcp"
  cidr_blocks = ["${var.vpc_cidr}"]
  security_group_id = "${aws_security_group.kubernetes.id}"
}

resource "aws_security_group_rule" "kubernetes_outbound" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = -1
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.kubernetes.id}"
}
