resource "aws_elb" "bosh_uaa_elb" {
  name = "${var.stack_description}-bosh-uaa"
  subnets = ["${module.stack.public_subnet_az1}" ,"${module.stack.public_subnet_az2}"]
  security_groups = ["${module.stack.web_traffic_security_group}"]

  listener {
    lb_port = 443
    lb_protocol = "HTTPS"
    instance_port = 8081
    instance_protocol = "HTTP"

    ssl_certificate_id = "${var.bosh_uaa_elb_cert_name != "" ?
      "arn:${local.aws_partition}:iam::${data.aws_caller_identity.current.account_id}:server-certificate/${var.bosh_uaa_elb_cert_name}" :
      data.aws_iam_server_certificate.wildcard_staging.arn}"
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
