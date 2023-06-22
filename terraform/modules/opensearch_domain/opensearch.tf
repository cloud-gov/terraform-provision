resource "aws_opensearch_domain" "opensearch" {
  domain_name    = var.domain_name
  engine_version = var.engine

  advanced_security_options {
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = var.master_user_name
      master_user_password = var.master_user_password
    }
  }

  cluster_config {
    instance_type          = var.instance_type
    zone_awareness_enabled = true
  }

  encrypt_at_rest {
    enabled = true
  }
 
  node_to_node_encryption {
    enabled = true
  }

  vpc_options {
    subnet_ids = var.private_elb_subnets
  }
}