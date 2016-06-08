output "username" {
  value = "${module.release_user.username}"
}

output "access_key_id" {
  value = "${module.release_user.access_key_id}"
}

output "secret_access_key" {
  value = "${module.release_user.secret_access_key}"
}