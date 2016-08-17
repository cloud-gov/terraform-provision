output "username" {
  value = "${module.kubernetes_master_user.username}"
}

output "access_key_id" {
  value = "${module.kubernetes_master_user.access_key_id}"
}

output "secret_access_key" {
  value = "${module.kubernetes_master_user.secret_access_key}"
}
