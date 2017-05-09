/* cdn broker user */
output "cdn_broker_username" {
  value = "${module.cdn_broker.username}"
}
output "cdn_broker_access_key_id_prev" {
  value = ""
}
output "cdn_broker_secret_access_key_prev" {
  value = ""
}
output "cdn_broker_access_key_id_curr" {
  value = "${module.cdn_broker.access_key_id_curr}"
}
output "cdn_broker_secret_access_key_curr" {
  value = "${module.cdn_broker.secret_access_key_curr}"
}

/* limit check user */
output "limit_check_username" {
  value = "${module.limit_check_user.username}"
}
output "limit_check_access_key_id_prev" {
  value = ""
}
output "limit_check_secret_access_key_prev" {
  value = ""
}
output "limit_check_access_key_id_curr" {
  value = "${module.limit_check_user.access_key_id_curr}"
}
output "limit_check_secret_access_key_curr" {
  value = "${module.limit_check_user.secret_access_key_curr}"
}
