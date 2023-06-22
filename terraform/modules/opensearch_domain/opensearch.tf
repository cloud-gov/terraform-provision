resource "aws_opensearch_domain" "example" {
  domain_name    = var.domain2
  engine_version = var.engine2

  cluster_config {
    instance_type          = var.instance_type2
    zone_awareness_enabled = true
  }
  vpc_options {
    subnet_ids = [aws_subnet.az1_public.id, aws_subnet.az2_public.id]
    security_group_ids = [aws_security_group.bosh.id]
  }
}