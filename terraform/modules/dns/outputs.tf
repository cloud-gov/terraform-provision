output "axfr_security_group" {
  value = aws_security_group.dns_axfr.id
}

output "public_security_group" {
  value = aws_security_group.dns_public.id
}

