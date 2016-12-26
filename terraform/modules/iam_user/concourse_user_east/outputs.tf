output "username" {
  value = "${module.concourse_user_east.username}"
}

output "access_key_id" {
  value = "${module.concourse_user_east.access_key_id}"
}

output "secret_access_key" {
  value = "${module.concourse_user_east.secret_access_key}"
}