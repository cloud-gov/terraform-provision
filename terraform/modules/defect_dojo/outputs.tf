output "defectdojo_subnet_az1" {
  value = aws_subnet.defectdojo_az1.id
}
output "defectdojo_subnet_az2" {
  value = aws_subnet.defectdojo_az2.id
}

output "defectdojo_subnet_cidr_az1" {
  value = aws_subnet.defectdojo_az1.cidr_block
}

output "defectdojo_subnet_cidr_az2" {
  value = aws_subnet.defectdojo_az2.cidr_block
}

output "defectdojo_security_group" {
  value = aws_security_group.defectdojo.id
}

/* RDS Defect Dojo Instance */
output "defectdojo_rds_identifier" {
  value = module.rds_96.rds_identifier
}

output "defectdojo_rds_name" {
  value = module.rds_96.rds_name
}

output "defectdojo_rds_host" {
  value = module.rds_96.rds_host
}

output "defectdojo_rds_port" {
  value = module.rds_96.rds_port
}

output "defectdojo_rds_url" {
  value = module.rds_96.rds_url
}

output "defectdojo_rds_username" {
  value = module.rds_96.rds_username
}

output "defectdojo_rds_password" {
  value     = module.rds_96.rds_password
  sensitive = true
}

output "defectdojo_lb_target_group" {
  value = aws_lb_target_group.defectdojo_target.name
}
