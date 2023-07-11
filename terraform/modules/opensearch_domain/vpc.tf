resource "aws_security_group" "opensearch_customer" {
  name        = "${var.domain_name}-incoming-opensearch"
  description = "Allow access to incoming opensearch traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = var.allow_incoming_traffic_security_group_ids
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = var.allow_incoming_traffic_security_group_ids
  }

  tags = {
    Name = "${var.domain_name} - Incoming Opensearch Traffic"
  }
}

