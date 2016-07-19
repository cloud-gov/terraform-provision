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
