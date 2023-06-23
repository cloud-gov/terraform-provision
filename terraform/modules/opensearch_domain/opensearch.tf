resource "aws_opensearch_domain" "opensearch" {
  domain_name    = var.domain_name
  engine_version = var.engine

  advanced_security_options {
    internal_user_database_enabled = var.internal_user_database_enabled
    master_user_options {
      master_user_name     = var.master_user_name
      master_user_password = var.master_user_password
    }
  }

  cluster_config {
    instance_type          = var.instance_type
    dedicated_master_count = var.dedicated_master_count
    dedicated_master_enabled = var.dedicated_master_enabled
    dedicated_master_type = var.dedicated_master_type
    instance_count = var.instance_count
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