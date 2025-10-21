output "dkim_attribute_tokens" {
  value     = aws_sesv2_email_identity.email_domain_identity.dkim_signing_attributes[0].tokens
  sensitive = true
}
