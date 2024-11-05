resource "random_password" "password" {
  length = 64
  # see https://docs.aws.amazon.com/AmazonElastiCache/latest/dg/auth.html#auth-overview
  override_special = "!&#$^<>-"
}

resource "aws_elasticache_replication_group" "replication_group" {
  replication_group_id       = "${var.cluster_name}-cluster"
  description                = "${var.cluster_name} cluster"
  node_type                  = var.node_type
  port                       = 6379
  auto_minor_version_upgrade = true
  auth_token                 = random_password.password.result

  engine             = var.engine
  engine_version     = var.engine_version
  num_cache_clusters = var.num_cache_clusters

  automatic_failover_enabled = true
  multi_az_enabled           = true

  transit_encryption_enabled = true
  at_rest_encryption_enabled = true

  subnet_group_name  = var.subnet_group_name
  security_group_ids = var.security_group_ids
}
