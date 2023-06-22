resource "aws_opensearch_domain" "opensearch" {
  domain_name    = var.domain
  engine_version = var.engine

  cluster_config {
    instance_type          = var.instance_type
    zone_awareness_enabled = true
  }

  vpc_options {
    subnet_ids = var.private_elb_subnets
    #security_group_ids = var.bosh_security_group
  }
}