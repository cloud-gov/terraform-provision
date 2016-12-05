/*
 * Variables required:
 *   stack_description
 *   elb_subnets
 *   elb_shibboleth_cert_name
 *   account_id
 *   aws_partition
 *   elb_security_groups
 *
 */

resource "aws_elb" "shibboleth_elb_main" {
  name = "${var.stack_description}-shibboleth-proxy"
  subnets = ["${split(",", var.elb_subnets)}"]
  security_groups = ["${split(",", var.elb_security_groups)}"]

  listener {
    lb_port = 443
    lb_protocol = "HTTPS"
    instance_port = 8080
    instance_protocol = "HTTP"

    ssl_certificate_id = "arn:${var.aws_partition}:iam::${var.account_id}:server-certificate/${var.elb_shibboleth_cert_name}"
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

resource "aws_lb_cookie_stickiness_policy" "shibboleth_elb_stickiness" {
  name = "${var.stack_description}-shibb-elb-cookie-policy"
  load_balancer = "${aws_elb.shibboleth_elb_main.id}"
  lb_port = 443
  cookie_expiration_period = 1800
}

resource "aws_app_cookie_stickiness_policy" "shibboleth_app_stickiness" {
  name = "${var.stack_description}-shibb-app-cookie-policy"
  load_balancer = "${aws_elb.shibboleth_elb_main.name}"
  lb_port = 443
  cookie_name = "JSESSIONID"
}