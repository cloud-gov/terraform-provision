output "username" {
  value = "${module.stemcell_user.username}"
}

output "access_key_id" {
  value = "${module.stemcell_user.access_key_id}"
}

output "secret_access_key" {
  value = "${module.stemcell_user.secret_access_key}"
}
