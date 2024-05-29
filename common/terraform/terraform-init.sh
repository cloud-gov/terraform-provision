init_args=(
  "-backend=true"
  "-backend-config=encrypt=true"
  "-backend-config=bucket=common-terraform-state"
  "-backend-config=key=terraform-state-bucket/terraform.tfstate"
)

terraform init "${init_args[@]}" -upgrade