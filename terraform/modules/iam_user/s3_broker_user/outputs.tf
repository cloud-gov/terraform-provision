output "username" {
  value = "${module.s3_broker_user.username}"
}

output "access_key_id" {
  value = "${module.s3_broker_user.access_key_id}"
}

output "secret_access_key" {
  value = "${module.s3_broker_user.secret_access_key}"
}
