output "dkim_attribute_tokens" {
  value     = aws_sesv2_email_identity.email_domain_identity.dkim_signing_attributes[0].tokens
  sensitive = true
}

output "ses_configuration_set_arn" {
  value = aws_sesv2_configuration_set.email_domain_identity_config.arn
}

output "ses_email_identity_arn" {
  value = aws_sesv2_email_identity.email_domain_identity.arn
}
