# New Hub

This stack is used before the bootstrap stack for new hubs to:

 - Create the terraform-provision iam user.  This will generate aws access key and secret needed to create a cg-provision.yml (aka credentials) file
 - Hopefully: the s3 backend and any other dependencies we don't yet know about



To run this stack, from a laptop with aws-vault access configured clone the repo and switch to the new stack:

```
git clone https://github.com/cloud-gov/cg-provision
cd cg-provision/terraform/stacks/bootstrap-hub
mkdir terraform-state
```



Now run the init and plan:

```
aws-vault exec gov-pipeline-admin -- bash

STACK_NAME=bootstrap-hub
BASE="$(pwd)"

init_args=(
  "-backend=true"
  "-backend-config=path=terraform-state/terraform.tfstate"
)

terraform init "${init_args[@]}" 


terraform plan -refresh=true -input=false -out=${BASE}/terraform-state/terraform.tfplan \
    > ${BASE}/terraform-state/terraform-plan-output.txt
```

To apply

```
terraform apply -refresh=true -input=false -auto-approve
```

This will output values for the `aws_access_key_id` and `aws_secret_access_key` for `credentials.yml` aka `cg-provision.yml`:

```
terraform_provision_access_id = "XXXXXXXXXXXXXXXXXXXX"
terraform_provision_access_secret = <sensitive>
```

To get the value of the access secret, run:

```
terraform output -json terraform_provision_access_secret
```