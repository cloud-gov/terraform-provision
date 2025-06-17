output "pages_buckets_manager_username" {
  value = module.pages_buckets_manager.username
}

output "pages_buckets_manager_access_key_id_prev" {
  value = module.pages_buckets_manager.access_key_id_prev
}

output "pages_buckets_manager_secret_access_key_prev" {
  value     = module.pages_buckets_manager.secret_access_key_prev
  sensitive = true
}

output "pages_buckets_manager_access_key_id_curr" {
  value = module.pages_buckets_manager.access_key_id_curr
}

output "pages_buckets_manager_secret_access_key_curr" {
  value     = module.pages_buckets_manager.secret_access_key_curr
  sensitive = true
}
