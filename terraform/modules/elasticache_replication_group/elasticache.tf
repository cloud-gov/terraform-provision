resource "aws_elasticache_replication_group" "replication_group" {
  replication_group_id       = "${var.cluster_name}-cluster"
  description                = "${var.cluster_name} cluster"
  node_type                  = var.node_type
  port                       = 6379
  auto_minor_version_upgrade = true

  engine             = var.engine
  engine_version     = var.engine_version
  num_cache_clusters = var.num_cache_clusters

  automatic_failover_enabled = true
  multi_az_enabled           = true

  transit_encryption_enabled = true
  at_rest_encryption_enabled = true
}
