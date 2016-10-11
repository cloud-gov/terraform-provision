resource "aws_security_group" "kubernetes_ec2" {
  description = "Allow access to incoming kubernetes traffic"
  vpc_id = "${var.vpc_id}"

  tags = {
    Name = "${var.stack_description} - Kubernetes EC2"
  }
}

resource "aws_security_group_rule" "self_reference" {
  type = "ingress"
  self = true
  from_port = 0
  to_port = 0
  protocol = -1
  security_group_id = "${aws_security_group.kubernetes_ec2.id}"
}

resource "aws_security_group_rule" "kubernetes_elb" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = -1
  source_security_group_id = "${aws_security_group.kubernetes_elb.id}"
  security_group_id = "${aws_security_group.kubernetes_ec2.id}"
}

resource "aws_security_group_rule" "consul_dns" {
  type = "ingress"
  from_port = 53
  to_port = 53
  protocol = "udp"
  source_security_group_id = "${var.target_bosh_security_group}"
  security_group_id = "${aws_security_group.kubernetes_ec2.id}"
}

resource "aws_security_group_rule" "outbound" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = -1
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.kubernetes_ec2.id}"
}

// TODO: Drop BOSH-related rules use BOSH security group after https://github.com/kubernetes/kubernetes/issues/26787 is resolved
// TODO: Lock down 8080 in BOSH security group and/or change Kubernetes insecure port

resource "aws_security_group_rule" "bosh_ssh" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["${var.vpc_cidr}"]
  security_group_id = "${aws_security_group.kubernetes_ec2.id}"
}

resource "aws_security_group_rule" "bosh_ssh_tooling" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["${var.tooling_vpc_cidr}"]
  security_group_id = "${aws_security_group.kubernetes_ec2.id}"
}

resource "aws_security_group_rule" "bosh_nats" {
  type = "ingress"
  from_port = 6868
  to_port = 6868
  protocol = "tcp"
  cidr_blocks = ["${var.vpc_cidr}"]
  security_group_id = "${aws_security_group.kubernetes_ec2.id}"
}

resource "aws_security_group_rule" "bosh_director" {
  type = "ingress"
  from_port = 25555
  to_port = 25555
  protocol = "tcp"
  cidr_blocks = ["${var.vpc_cidr}"]
  security_group_id = "${aws_security_group.kubernetes_ec2.id}"
}
