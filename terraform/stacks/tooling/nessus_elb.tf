resource "aws_elb" "nessus_elb" {
  name = "${var.stack_description}-Nessus"
  subnets = ["${module.stack.public_subnet_az1}", "${module.stack.public_subnet_az2}"] 
  security_groups = ["${module.stack.restricted_web_traffic_security_group}"]

  listener {
    lb_port = 443
    lb_protocol = "HTTPS"
    instance_port = 8834
    instance_protocol = "HTTPS"

    ssl_certificate_id = "arn:${local.aws_partition}:iam::${data.aws_caller_identity.current.account_id}:server-certificate/${var.nessus_elb_cert_name}"
  }

  health_check {
    healthy_threshold = 2
    interval = 61
    target = "SSL:8834"
    timeout = 60
    unhealthy_threshold = 3
  }

  tags {
    Name = "${var.stack_description}-Nessus"
  }
}

resource "aws_lb_target_group" "nessus_target" {
  name     = "${var.stack_description}-nessus"
  port     = 8834
  protocol = "HTTPS"
  vpc_id   = "${module.stack.vpc_id}"

  health_check {
    protocol = "HTTPS"
    healthy_threshold = 2
    interval = 61
    timeout = 60
    unhealthy_threshold = 3
    matcher = 200
  }
}

resource "aws_lb_listener_rule" "nessus_listener_rule" {
  listener_arn = "${aws_lb_listener.main.arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.nessus_target.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${var.nessus_hosts}"]
  }
}
