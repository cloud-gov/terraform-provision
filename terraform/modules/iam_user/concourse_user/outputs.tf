output "username" {
  value = "${module.concourse_user.username}"
}

output "access_key_id" {
  value = "${module.concourse_user.access_key_id}"
}

output "secret_access_key" {
  value = "${module.concourse_user.secret_access_key}"
}