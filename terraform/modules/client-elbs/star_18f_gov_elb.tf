resource "aws_elb" "star_18f_gov_elb" {
  count = "${var.count}"

  name = "${var.stack_description}-star-18f-gov-elb"
  subnets = ["${var.elb_subnets}"]
  security_groups = ["${var.elb_security_groups}"]

  listener {
    lb_port = 80
    lb_protocol = "HTTP"
    instance_port = 80
    instance_protocol = "HTTP"
  }

  listener {
    lb_port = 443
    lb_protocol = "HTTPS"
    instance_port = 80
    instance_protocol = "HTTP"

    ssl_certificate_id = "${var.star_18f_gov_cert_id}"
  }

  health_check {
    healthy_threshold = 2
    interval = 5
    target = "TCP:80"
    timeout = 4
    unhealthy_threshold = 3
  }

  tags = {
    Name = "${var.stack_description}-star-18f-gov-elb"
  }
}
