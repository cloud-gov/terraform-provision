resource "aws_opensearch_domain" "opensearch" {
  domain_name    = var.domain_name
  engine_version = var.engine

  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = var.internal_user_database_enabled
    master_user_options {
      master_user_name     = var.master_user_name
      master_user_password = var.master_user_password
    }
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 15
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  cluster_config {
    instance_type            = var.instance_type
    dedicated_master_count   = var.dedicated_master_count
    dedicated_master_enabled = var.dedicated_master_enabled
    dedicated_master_type    = var.dedicated_master_type
    instance_count           = var.instance_count
    zone_awareness_enabled   = true
  }

  encrypt_at_rest {
    enabled = true
  }

  node_to_node_encryption {
    enabled = true
  }

  vpc_options {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.opensearch_customer.id]
  }
}
