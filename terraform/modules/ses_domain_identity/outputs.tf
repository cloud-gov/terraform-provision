output "dkim_attributes" {
  value     = aws_sesv2_email_identity.email_domain_identity.dkim_signing_attributes
  sensitive = true
}
