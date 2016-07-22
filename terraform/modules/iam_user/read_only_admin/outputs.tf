output "username" {
  value = "${module.read_only_admin.username}"
}

output "access_key_id" {
  value = "${module.read_only_admin.access_key_id}"
}

output "secret_access_key" {
  value = "${module.read_only_admin.secret_access_key}"
}
