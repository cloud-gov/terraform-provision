output "public_subnet_id" {
  value = aws_default_subnet.default_az1.id
}

output "public_subnet_cidr" {
  value = aws_default_subnet.default_az1.cidr_block
}

output "public_subnet_gateway" {
  value = cidrhost(aws_default_subnet.default_az1.cidr_block, 1)
}

output "private_ip" {
  value = cidrhost(aws_default_subnet.default_az1.cidr_block, 100)
}

output "public_ip" {
  value = aws_eip.bootstrap.public_ip
}

output "security_group_id" {
  value = aws_security_group.bootstrap.id
}

output "varz_bucket" {
    value = module.varz_bucket.bucket_name
}

output "varz_bucket_stage" {
    value = module.varz_bucket_staging.bucket_name
}

output "semver_bucket" {
    value = module.semver_bucket.bucket_name
}




