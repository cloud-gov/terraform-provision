/* health check user */
output "health_check_user_username" {
  value = module.health_check.username
}

output "health_check_user_access_key_id_prev" {
  value = module.health_check.access_key_id_prev
}

output "health_check_user_secret_access_key_prev" {
  value = module.health_check.secret_access_key_prev
}

output "health_check_user_access_key_id_curr" {
  value = module.health_check.access_key_id_curr
}

output "health_check_user_secret_access_key_curr" {
  value = module.health_check.secret_access_key_curr
}

/* external domain broker user */
output "external_domain_broker_username" {
  value = module.external_domain_broker.username
}

output "external_domain_broker_access_key_id_prev" {
  value = module.external_domain_broker.access_key_id_prev
}

output "external_domain_broker_secret_access_key_prev" {
  value = module.external_domain_broker.secret_access_key_prev
}

output "external_domain_broker_access_key_id_curr" {
  value = module.external_domain_broker.access_key_id_curr
}

output "external_domain_broker_secret_access_key_curr" {
  value = module.external_domain_broker.secret_access_key_curr
}

/* external domain broker test user */
output "external_domain_broker_tests_username" {
  value = module.external_domain_broker_tests.username
}

output "external_domain_broker_tests_access_key_id_prev" {
  value = module.external_domain_broker_tests.access_key_id_prev
}

output "external_domain_broker_tests_secret_access_key_prev" {
  value = module.external_domain_broker_tests.secret_access_key_prev
}

output "external_domain_broker_tests_access_key_id_curr" {
  value = module.external_domain_broker_tests.access_key_id_curr
}

output "external_domain_broker_tests_secret_access_key_curr" {
  value = module.external_domain_broker_tests.secret_access_key_curr
}

/* cdn broker user */
output "cdn_broker_username" {
  value = module.cdn_broker.username
}

output "cdn_broker_access_key_id_prev" {
  value = module.cdn_broker.access_key_id_prev
}

output "cdn_broker_secret_access_key_prev" {
  value = module.cdn_broker.secret_access_key_prev
}

output "cdn_broker_access_key_id_curr" {
  value = module.cdn_broker.access_key_id_curr
}

output "cdn_broker_secret_access_key_curr" {
  value = module.cdn_broker.secret_access_key_curr
}

/* limit check user */
output "limit_check_username" {
  value = module.limit_check_user.username
}

output "limit_check_access_key_id_prev" {
  value = module.limit_check_user.access_key_id_prev
}

output "limit_check_secret_access_key_prev" {
  value = module.limit_check_user.secret_access_key_prev
}

output "limit_check_access_key_id_curr" {
  value = module.limit_check_user.access_key_id_curr
}

output "limit_check_secret_access_key_curr" {
  value = module.limit_check_user.secret_access_key_curr
}

/* lets encrypt user */
output "lets_encrypt_username" {
  value = module.lets_encrypt_user.username
}

output "lets_encrypt_access_key_id_prev" {
  value = module.lets_encrypt_user.access_key_id_prev
}

output "lets_encrypt_secret_access_key_prev" {
  value = module.lets_encrypt_user.secret_access_key_prev
}

output "lets_encrypt_access_key_id_curr" {
  value = module.lets_encrypt_user.access_key_id_curr
}

output "lets_encrypt_secret_access_key_curr" {
  value = module.lets_encrypt_user.secret_access_key_curr
}

// Domain Broker v2
output "domain_broker_v2" {
  value = module.domain_broker_v2_user.username
}

output "domain_broker_v2_access_key_id_prev" {
  value = module.domain_broker_v2_user.access_key_id_prev
}

output "domain_broker_v2_secret_access_key_prev" {
  value = module.domain_broker_v2_user.secret_access_key_prev
}

output "domain_broker_v2_access_key_id_curr" {
  value = module.domain_broker_v2_user.access_key_id_curr
}

output "domain_broker_v2_secret_access_key_curr" {
  value = module.domain_broker_v2_user.secret_access_key_curr
}

