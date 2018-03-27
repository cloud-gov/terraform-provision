resource "aws_elb" "shibboleth_elb_main" {
  name = "${var.stack_description}-shibboleth-proxy"
  subnets = ["${var.elb_subnets}"]
  security_groups = ["${var.elb_security_groups}"]

  listener {
    lb_port = 443
    lb_protocol = "HTTPS"
    instance_port = 8080
    instance_protocol = "HTTP"

    ssl_certificate_id = "${var.elb_shibboleth_cert_id}"
  }

  health_check {
    healthy_threshold = 2
    interval = 15
    target = "HTTP:8080/shibboleth"
    timeout = 10
    unhealthy_threshold = 2
  }

  tags =  {
    Name = "${var.stack_description}-shibboleth-Proxy-ELB"
  }

}

resource "aws_app_cookie_stickiness_policy" "shibboleth_jsession_stickiness" {
  name = "${var.stack_description}-shibboleth-sticky-jsession"
  load_balancer = "${aws_elb.shibboleth_elb_main.name}"
  cookie_name = "JSESSIONID"
  lb_port = 443
}

resource "aws_lb_target_group" "shibboleth" {
  name     = "${var.stack_description}-shibboleth"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    healthy_threshold = 2
    interval = 15
    path = "/shibboleth"
    timeout = 10
    unhealthy_threshold = 2
    matcher = 200
  }

  stickiness {
    type = "lb_cookie"
    enabled = true
  }
}

resource "aws_lb_listener_rule" "shibboleth" {
  count = "${length(var.hosts)}"

  listener_arn = "${var.listener_arn}"
  priority = ${100 + count.index}

  action {
    target_group_arn = "${aws_lb_target_group.shibboleth.arn}"
    type             = "forward"
  }

  condition {
    field  = "host-header"
    values = ["${element(var.hosts, count.index)}"]
  }
}
