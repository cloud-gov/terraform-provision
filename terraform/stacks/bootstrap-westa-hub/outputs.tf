

output "terraform_provision_access_id" {
  value = module.terraform_provision_user.terraform_provision_access_id_curr
}

output "terraform_provision_access_secret" {
  value     = module.terraform_provision_user.terraform_provision_access_secret_curr
  sensitive = true
}

output "aws_s3_tfstate_bucket" {
  value = module.tfstate_bucket.bucket_name
}
