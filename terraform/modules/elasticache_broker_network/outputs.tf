output "elasticache_subnet_az1" {
  value = aws_subnet.az1_elasticache.id
}

output "elasticache_subnet_az2" {
  value = aws_subnet.az2_elasticache.id
}

output "elasticache_private_cidr_1" {
  value = aws_subnet.az1_elasticache.cidr_block
}

output "elasticache_private_cidr_2" {
  value = aws_subnet.az2_elasticache.cidr_block
}

output "elasticache_subnet_group" {
  value = aws_elasticache_subnet_group.elasticache.id
}

output "elasticache_redis_security_group" {
  value = aws_security_group.elasticache_redis.id
}

output "elasticache_elb_dns_name" {
  value = aws_elb.elasticache_elb.dns_name
}

output "elasticache_elb_name" {
  value = aws_elb.elasticache_elb.name
}

