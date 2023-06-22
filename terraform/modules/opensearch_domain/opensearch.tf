resource "aws_opensearch_domain" "example" {
  domain_name    = var.domain
  engine_version = var.engine

  cluster_config {
    instance_type          = var.instance_type
    zone_awareness_enabled = true
  }
  vpc_options {
    subnet_ids = [aws_subnet.az1_public.id, aws_subnet.az2_public.id]
    security_group_ids = [aws_security_group.bosh.id]
  }
}