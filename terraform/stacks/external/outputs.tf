/* cdn broker user */
output "cdn_broker_username" {
  value = "${module.cdn_broker.username}"
}
output "cdn_broker_access_key_id" {
  value = "${module.cdn_broker.access_key_id}"
}
output "cdn_broker_secret_access_key" {
  value = "${module.cdn_broker.secret_access_key}"
}

/* limit check user */
output "limit_check_username" {
  value = "${module.limit_check_user.username}"
}
output "limit_check_access_key_id" {
  value = "${module.limit_check_user.access_key_id}"
}
output "limit_check_secret_access_key" {
  value = "${module.limit_check_user.secret_access_key}"
}
