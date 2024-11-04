variable "cluster_name" {
  type        = string
  description = "Name of the cluster"
}

variable "node_type" {
  type        = string
  default     = "cache.t3.small"
  description = "Node type to use for Elasticache cluster"
}

variable "engine" {
  type        = string
  description = "Engine to use for Elasticache cluster (e.g. redis, valkey)"
  default     = "redis"
}

variable "engine_version" {
  type        = string
  description = "Engine version use for Elasticache cluster"
  default     = "7.1"
}

variable "num_cache_clusters" {
  type        = number
  description = "Number of cache clusters to use"
  default     = 3
}

variable "subnet_group_name" {
  type        = string
  description = "Name of subnet group to use for Elasticache cluster"
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of security group IDs to apply to the Elasticache cluster"
}
