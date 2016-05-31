
resource "aws_security_group_rule" "bosh_ssh" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.source_vpc_cidr}"]
    security_group_id = "${var.target_bosh_security_group}"
}

resource "aws_security_group_rule" "dns" {
    type = "ingress"
    from_port = 53
    to_port = 53
    protocol = "tcp"
    cidr_blocks = ["${var.source_vpc_cidr}"]
    security_group_id = "${var.target_bosh_security_group}"
}

resource "aws_security_group_rule" "bosh_nats" {
    type = "ingress"
    from_port = 6868
    to_port = 6868
    protocol = "tcp"
    cidr_blocks = ["${var.source_vpc_cidr}"]
    security_group_id = "${var.target_bosh_security_group}"
}

resource "aws_security_group_rule" "bosh_director" {
    type = "ingress"
    from_port = 25555
    to_port = 25555
    protocol = "tcp"
    cidr_blocks = ["${var.source_vpc_cidr}"]
    security_group_id = "${var.target_bosh_security_group}"
}