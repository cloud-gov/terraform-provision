resource "aws_elb" "logsearch_elb" {
  name            = "${var.stack_description}-logsearch"
  subnets         = var.private_elb_subnets
  security_groups = [var.bosh_security_group]
  idle_timeout    = 3600
  internal        = true

  listener {
    instance_port     = 9200
    instance_protocol = "tcp"
    lb_port           = 9200
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 5
    target              = "HTTP:9200/_cluster/health?local"
    interval            = 30
  }

  tags = {
    Name = "${var.stack_description}-logsearch"
  }

  access_logs {
    bucket        = var.elb_log_bucket_name
    bucket_prefix = var.stack_description
    enabled       = true
  }
}

