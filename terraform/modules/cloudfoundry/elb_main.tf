resource "aws_elb" "cloudfoundry_elb_main" {
  name = "${var.stack_description}-CloudFoundry-Main"
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

    ssl_certificate_id = "${var.elb_main_cert_id}"
  }

  health_check {
    healthy_threshold = 2
    interval = 5
    target = "HTTP:81/"
    timeout = 4
    unhealthy_threshold = 3
  }

  tags {
    Name = "${var.stack_description}-CloudFoundry-Main"
  }
}
