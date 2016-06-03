output "username" {
  value = "${module.bosh_user.username}"
}

output "access_key_id" {
  value = "${module.bosh_user.access_key_id}"
}

output "secret_access_key" {
  value = "${module.bosh_user.secret_access_key}"
}