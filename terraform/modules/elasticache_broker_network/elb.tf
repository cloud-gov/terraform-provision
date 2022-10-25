resource "aws_elb" "elasticache_elb" {
  name            = "${var.stack_description}-elasticache-broker"
  subnets         = var.elb_subnets
  security_groups = var.elb_security_groups
  internal        = true
  
  enable_deletion_protection  = true

  listener {
    lb_port           = 80
    lb_protocol       = "HTTP"
    instance_port     = 80
    instance_protocol = "HTTP"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 10
    timeout             = 5
    target              = "HTTP:80/healthcheck"
  }

  tags = {
    Name = "${var.stack_description}-elasticache-broker"
  }

  access_logs {
    bucket        = var.log_bucket_name
    bucket_prefix = var.stack_description
    enabled       = true
  }
}

