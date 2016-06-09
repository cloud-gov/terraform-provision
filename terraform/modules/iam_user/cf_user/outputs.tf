output "username" {
  value = "${module.cf_user.username}"
}

output "access_key_id" {
  value = "${module.cf_user.access_key_id}"
}

output "secret_access_key" {
  value = "${module.cf_user.secret_access_key}"
}