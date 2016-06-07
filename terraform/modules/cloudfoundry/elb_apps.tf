resource "aws_elb" "cloudfoundry_elb_apps" {
  name = "${var.stack_description}-CloudFoundry-Apps"
  subnets = ["${split(",", var.elb_subnets)}"]
  security_groups = ["${split(",", var.elb_security_groups)}"]

  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = 80
    instance_protocol = "http"
  }

  listener {
    lb_port = 443
    lb_protocol = "https"
    instance_port = 80
    instance_protocol = "http"

    ssl_certificate_id = "arn:aws-us-gov:iam::${var.account_id}:server-certificate/${var.elb_apps_cert_name}"
  }

  health_check {
    healthy_threshold = 2
    interval = 5
    target = "TCP:80"
    timeout = 4
    unhealthy_threshold = 3
  }

  tags =  {
    Name = "${var.stack_description}-CloudFoundry-Apps"
  }

}
