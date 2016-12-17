output "username" {
  value = "${module.go_s3_broker_user.username}"
}

output "access_key_id" {
  value = "${module.go_s3_broker_user.access_key_id}"
}

output "secret_access_key" {
  value = "${module.go_s3_broker_user.secret_access_key}"
}
