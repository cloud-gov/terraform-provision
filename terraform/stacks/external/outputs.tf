/* health check user */
output "health_check_user_username" {
  value = module.health_check_user.username
}

output "health_check_user_access_key_id_prev" {
  value = module.health_check_user.access_key_id_prev
}

output "health_check_user_secret_access_key_prev" {
  value     = module.health_check_user.secret_access_key_prev
  sensitive = true
}

output "health_check_user_access_key_id_curr" {
  value = module.health_check_user.access_key_id_curr
}

output "health_check_user_secret_access_key_curr" {
  value     = module.health_check_user.secret_access_key_curr
  sensitive = true
}

/* external domain broker user */
output "external_domain_broker_username" {
  value = module.external_domain_broker.username
}

output "external_domain_broker_access_key_id_prev" {
  value = module.external_domain_broker.access_key_id_prev
}

output "external_domain_broker_secret_access_key_prev" {
  value     = module.external_domain_broker.secret_access_key_prev
  sensitive = true
}

output "external_domain_broker_access_key_id_curr" {
  value = module.external_domain_broker.access_key_id_curr
}

output "external_domain_broker_secret_access_key_curr" {
  value     = module.external_domain_broker.secret_access_key_curr
  sensitive = true
}

output "external_domain_broker_rate_limit_group_arn" {
  value = module.external_domain_broker.waf_rate_limit_group_arn
}

/* external domain broker test user */
output "external_domain_broker_tests_username" {
  value = module.external_domain_broker_tests.username
}

output "external_domain_broker_tests_access_key_id_prev" {
  value = module.external_domain_broker_tests.access_key_id_prev
}

output "external_domain_broker_tests_secret_access_key_prev" {
  value     = module.external_domain_broker_tests.secret_access_key_prev
  sensitive = true
}

output "external_domain_broker_tests_access_key_id_curr" {
  value = module.external_domain_broker_tests.access_key_id_curr
}

output "external_domain_broker_tests_secret_access_key_curr" {
  value     = module.external_domain_broker_tests.secret_access_key_curr
  sensitive = true
}

/* cdn broker user */
output "cdn_broker_username" {
  value = module.cdn_broker.username
}

output "cdn_broker_access_key_id_prev" {
  value = module.cdn_broker.access_key_id_prev
}

output "cdn_broker_secret_access_key_prev" {
  value     = module.cdn_broker.secret_access_key_prev
  sensitive = true
}

output "cdn_broker_access_key_id_curr" {
  value = module.cdn_broker.access_key_id_curr
}

output "cdn_broker_secret_access_key_curr" {
  value     = module.cdn_broker.secret_access_key_curr
  sensitive = true
}

/* limit check user */
output "limit_check_username" {
  value = module.limit_check_user.username
}

output "limit_check_access_key_id_prev" {
  value = module.limit_check_user.access_key_id_prev
}

output "limit_check_secret_access_key_prev" {
  value     = module.limit_check_user.secret_access_key_prev
  sensitive = true
}

output "limit_check_access_key_id_curr" {
  value = module.limit_check_user.access_key_id_curr
}

output "limit_check_secret_access_key_curr" {
  value     = module.limit_check_user.secret_access_key_curr
  sensitive = true
}

/* lets encrypt user */
output "lets_encrypt_username" {
  value = module.lets_encrypt_user.username
}

output "lets_encrypt_access_key_id_prev" {
  value = module.lets_encrypt_user.access_key_id_prev
}

output "lets_encrypt_secret_access_key_prev" {
  value     = module.lets_encrypt_user.secret_access_key_prev
  sensitive = true
}

output "lets_encrypt_access_key_id_curr" {
  value = module.lets_encrypt_user.access_key_id_curr
}

output "lets_encrypt_secret_access_key_curr" {
  value     = module.lets_encrypt_user.secret_access_key_curr
  sensitive = true
}

output "csb_access_key_id_curr" {
  value = module.csb_iam.access_key_id_curr
}

output "csb_secret_access_key_curr" {
  sensitive = true
  value     = module.csb_iam.secret_access_key_curr
}
