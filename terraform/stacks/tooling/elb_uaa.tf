resource "aws_elb" "bosh_uaa_elb" {
  name = "${var.stack_description}-bosh-uaa"
  subnets = ["${module.stack.public_subnet_az1}" ,"${module.stack.public_subnet_az2}"]
  security_groups = ["${module.stack.web_traffic_security_group}"]

  listener {
    lb_port = 443
    lb_protocol = "HTTPS"
    instance_port = 8081
    instance_protocol = "HTTP"

    ssl_certificate_id = "arn:${var.aws_partition}:iam::${var.account_id}:server-certificate/${var.bosh_uaa_elb_cert_name}"
  }

  health_check {
    healthy_threshold = 2
    interval = 61
    target = "TCP:8081"
    timeout = 60
    unhealthy_threshold = 3
  }

  tags {
    Name = "${var.stack_description}-bosh-uaa"
  }
}

resource "aws_app_cookie_stickiness_policy" "opslogin_jsession_stickiness" {
  name = "${var.stack_description}-opslogin-sticky-jsession"
  load_balancer = "${aws_elb.bosh_uaa_elb.name}"
  lb_port = 443
  cookie_name = "JSESSIONID"
}