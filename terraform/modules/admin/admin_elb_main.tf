resource "aws_lb" "admin" {
  name = "${var.stack_description}-admin"
  subnets = ["${var.public_subnet_az1}", "${var.public_subnet_az2}"]
  security_groups = ["${var.security_group}"]
  ip_address_type = "dualstack"
  idle_timeout = 3600
}

resource "aws_lb_listener" "admin" {
  load_balancer_arn = "${aws_lb.admin.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn = "${var.certificate_arn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.admin.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "admin" {
  name     = "${var.stack_description}-admin"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    healthy_threshold = 2
    interval = 15
    path = "/health"
    timeout = 10
    unhealthy_threshold = 2
    matcher = 200
  }
}

resource "aws_lb_listener_rule" "admin" {
  count = "${length(var.hosts)}"

  listener_arn = "${aws_lb_listener.admin.arn}"
  priority = "${100 + count.index}"

  action {
    target_group_arn = "${aws_lb_target_group.admin.arn}"
    type             = "forward"
  }

  condition {
    field  = "host-header"
    values = ["${element(var.hosts, count.index)}"]
  }
}
