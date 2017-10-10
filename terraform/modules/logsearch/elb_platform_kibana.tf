resource "aws_elb" "platform_kibana_elb" {
  name = "${var.stack_description}-platform-kibana"
  subnets = ["${var.public_elb_subnets}"]
  security_groups = ["${var.restricted_security_group}"]
  idle_timeout = 3600

  listener {
    lb_port = 443
    lb_protocol = "https"
    instance_port = 5600
    instance_protocol = "http"
    ssl_certificate_id = "arn:${var.aws_partition}:iam::${var.account_id}:server-certificate/${var.elb_cert_name}"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 10
    timeout = 5
    target = "TCP:5600"
    interval = 30
  }

  tags {
    Name = "${var.stack_description}-platform-kibana"
  }
}
