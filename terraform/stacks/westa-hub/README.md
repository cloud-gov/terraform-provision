# Create new tooling environment

This stack is run after `bootstrap` and `bootstrap-westa-hub` are created so that there is an s3 bucket to store the state file for this terraform run.

## First deployment - Create Certificates

Certificates need to be created for production and staging, the steps below are loosly modeled after `ci/provision_certificate.*` and `ci/udpate_certificate.*`

***Note that this uses the `com-prd-plat-admin` commercial account, not the govcloud account.***

***Note you will need to disable zscaler to run certbot commands.***

```
git clone https://github.com/cloud-gov/cg-provision
cd cg-provision

aws-vault exec com-prd-plat-admin -- bash
export AWS_CA_BUNDLE=$(brew --prefix)/etc/ca-certificates/cert.pem

arch -arm64 brew install python3  #If running on M1 mac
pip3 install certbot certbot-dns-route53 --trusted-host pypi.org --trusted-host files.pythonhosted.org

mkdir -p certs/production
mkdir -p certs/staging 
cd certs


export EMAIL='cloud-gov-operations@gsa.gov'
export ACME_SERVER="https://acme-v02.api.letsencrypt.org/directory"



# Production
export config_path_production=$(pwd)/production
export DOMAIN_PRODUCTION="*.westa.cloud.gov"

certbot certonly \
  -n --agree-tos \
  --server "${ACME_SERVER:-https://acme-staging-v02.api.letsencrypt.org/directory}" \
  --dns-route53 \
  --config-dir "${config_path_production}" \
  --work-dir "${config_path_production}" \
  --logs-dir "${config_path_production}" \
  --email "${EMAIL}" \
  --domain "${DOMAIN_PRODUCTION}" 

# Staging
export config_path_staging=$(pwd)/staging
export DOMAIN_STAGING="*.westa-stage.cloud.gov"
certbot certonly \
  -n --agree-tos \
  --server "${ACME_SERVER:-https://acme-staging-v02.api.letsencrypt.org/directory}" \
  --dns-route53 \
  --config-dir "${config_path_staging}" \
  --work-dir "${config_path_staging}" \
  --logs-dir "${config_path_staging}" \
  --email "${EMAIL}" \
  --domain "${DOMAIN_STAGING}" 
```

If successful, you will see output similar to the following for production (staging will be similar):

```
Requesting a certificate for *.westa.cloud.gov

Successfully received certificate.
Certificate is saved at: /Users/pickles/projects/cg-provision/certs/production/live/westa.cloud.gov/fullchain.pem
Key is saved at:         /Users/pickles/projects/cg-provision/certs/production/live/westa.cloud.gov/privkey.pem
This certificate expires on 2023-09-05.
These files will be updated when the certificate renews.
```

***Note you can safely re-enable zscaler now.***


### Upload new certificates

You'll need to target the new govcloud account and run from the root of the `cg-provision` repo:

```
aws-vault exec gov-pipeline-admin -- bash
export AWS_CA_BUNDLE=$(brew --prefix)/etc/ca-certificates/cert.pem

cd certs

# Production
export config_path_production=$(pwd)/production
export CERT_PATH_PRODUCTION="/lets-encrypt/production/"
export CERT_PREFIX_PRODUCTION="star.westa.cloud.gov"
export out_path_production=$(ls -d -1 ${config_path_production}/live/*/) 

aws iam upload-server-certificate \
  --path "${CERT_PATH_PRODUCTION}" \
  --server-certificate-name "${CERT_PREFIX_PRODUCTION}-$(date +%Y-%m-%d-%H-%M)" \
  --certificate-body file://${out_path_production}/cert.pem \
  --certificate-chain file://${out_path_production}/chain.pem \
  --private-key file://${out_path_production}/privkey.pem

# Staging
export config_path_staging=$(pwd)/staging
export CERT_PATH_STAGING="/lets-encrypt/staging/"
export CERT_PREFIX_STAGING="star.westa-stage.cloud.gov"
export out_path_staging=$(ls -d -1 ${config_path_staging}/live/*/) 


aws iam upload-server-certificate \
  --path "${CERT_PATH_STAGING}" \
  --server-certificate-name "${CERT_PREFIX_STAGING}-$(date +%Y-%m-%d-%H-%M)" \
  --certificate-body file://${out_path_staging}/cert.pem \
  --certificate-chain file://${out_path_staging}/chain.pem \
  --private-key file://${out_path_staging}/privkey.pem

```

You should see output similar to:

```
{
    "ServerCertificateMetadata": {
        "Path": "/lets-encrypt/production/",
        "ServerCertificateName": "star.westa.cloud.gov-2023-06-07-10-44",
        "ServerCertificateId": "ASCAXXXXXXXXXXXXXXXXX",
        "Arn": "arn:aws-us-gov:iam::000000000000:server-certificate/lets-encrypt/production/star.westa.cloud.gov-2023-06-07-10-44",
        "UploadDate": "2023-06-07T14:44:55Z",
        "Expiration": "2023-09-05T13:34:54Z"
    }
}
{
    "ServerCertificateMetadata": {
        "Path": "/lets-encrypt/staging/",
        "ServerCertificateName": "star.westa-stage.cloud.gov-2023-06-07-10-48",
        "ServerCertificateId": "ASCAXXXXXXXXXXXXXXXXX",
        "Arn": "arn:aws-us-gov:iam::000000000000:server-certificate/lets-encrypt/staging/star.westa-stage.cloud.gov-2023-06-07-10-48",
        "UploadDate": "2023-06-07T14:48:56Z",
        "Expiration": "2023-09-05T13:36:59Z"
    }
}
```

To list the certificates:

```
aws iam list-server-certificates --path-prefix "${CERT_PATH_PRODUCTION}" --no-paginate
aws iam list-server-certificates --path-prefix "${CERT_PATH_STAGING}" --no-paginate
```

### Workarounds

If you get the error below, you are using the wrong aws-vault account:

```
Encountered exception during recovery: certbot.errors.PluginError: Unable to find a Route53 hosted zone for _acme-challenge.westa.cloud.gov
Unable to find a Route53 hosted zone for _acme-challenge.westa.cloud.gov
```


If you get the following error message, run `brew install ca-certificates ; export AWS_CA_BUNDLE=$(brew --prefix)/etc/ca-certificates/cert.pem` and run the `certbot` command again:

```
Requesting a certificate for *.westa.cloud.gov
Encountered exception during recovery: botocore.exceptions.SSLError: SSL validation failed for https://route53.amazonaws.com/2013-04-01/hostedzone [SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed: unable to get local issuer certificate (_ssl.c:1002)
An unexpected error occurred:
botocore.exceptions.SSLError: SSL validation failed for https://route53.amazonaws.com/2013-04-01/hostedzone [SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed: unable to get local issuer certificate (_ssl.c:1002)
```


## First deployment - Create tfvars file

Be sure to have created the certificates in the previous section before attempting to deploy the stack for the first time.

A couple notes:

 - `TF_VAR_*` are not used since they would be commited in github history and contain ip addresses.  Instead, use a `<stackname>.tfvars` file that you create and manually upload to the terraform state bucket.
 - `wildcard_production_certificate_name_prefix` should match the value in `CERT_PREFIX_PRODUCTION` in the previous section.
 - `wildcard_staging_certificate_name_prefix` should match the value in `CERT_PREFIX_STAGING` in the previous section.
 - `aws-vault` needs to use the new govcloud account for this hub and should match where the certificates were uploaded (not created) to.
 - The URLs for `TF_VAR_*_hosts` variables are defined in: https://github.com/cloud-gov/internal-docs/blob/main/docs/ADRs/design-decisions/hub-spoke-naming.md
 - `vpc_cidr` CIDR ranges have been mapped out to https://docs.google.com/spreadsheets/d/1oF8w6Tme2hYdcZCgW1Y7jq-Okmfu7CXvtCIGjkfFa4Q/edit#gid=0


Create a tfvars file and upload it to the terraform state s3 bucket:

```
aws-vault exec gov-pipeline-admin -- bash
export STACK_NAME=westa-hub
export S3_TFSTATE_BUCKET=westa-hub-terraform-state

vim "${STACK_NAME}.tfvars"                  # And create the file (TODO: create example file)
aws s3 cp "${STACK_NAME}.tfvars" "s3://${S3_TFSTATE_BUCKET}/${STACK_NAME}/${STACK_NAME}.tfvars" --sse AES256
```


## First deployment - Creating resources (aka: run the terraform)

Now we can move on to deploying this stack manually leveraging `aws-vault`:

```
git clone https://github.com/cloud-gov/cg-provision
cd cg-provision/terraform/stacks/westa-hub
```


Now run the init, pull down the tfvars file and apply:

```
aws-vault exec gov-pipeline-admin -- bash

export STACK_NAME=westa-hub
export S3_TFSTATE_BUCKET=westa-hub-terraform-state

# Note: the rest of the variables are in the westa-hub.tfvars file, grab a copy from the s3 bucket
aws s3 cp "s3://${S3_TFSTATE_BUCKET}/${STACK_NAME}/${STACK_NAME}.tfvars" "${STACK_NAME}.tfvars" --sse AES256

init_args=(
  "-backend=true"
  "-backend-config=encrypt=true"
  "-backend-config=bucket=${S3_TFSTATE_BUCKET}"
  "-backend-config=key=${STACK_NAME}/terraform.tfstate"
)

terraform init "${init_args[@]}" -upgrade

terraform apply -var-file="${STACK_NAME}.tfvars"
```



If running this from an m1 mac you may need to install:

```
brew install kreuzwerker/taps/m1-terraform-provider-helper
m1-terraform-provider-helper activate
m1-terraform-provider-helper install hashicorp/template -v v2.2.0
```

If you see an error releated to iam roles `role/bosh-passed/*`, you will need to edit the iam.tf file. 
- Search for `passed` and comment out the `iam_assume_role_policy` blocks. There are 6 total roles you will need to do this for.
- Rerun `terraform apply`.
- Remove the comments you added above.
- Rerun `terraform apply`.

### Creating a jumpbox

This is a temporary EC2 instance to live as long as needed to bootstrap the protoBOSH and Tooling BOSH.

In the tfvars file add the following line and run the terraform:

```
create_jumpbox = "true"
```

To know which EC2 instance was created as the jumpbox, run:

```
terraform show -json | jq -r ".values.outputs.jumpbox_instance_id.value"
```

Once the EC2 instance is created, navigate to AWS Console > EC2 > Select the new EC2 Instance > Connect > Session Manager > Connect.

This will connect via a web browser to a terminal session, it is suggested to switch to the `bash` shell once connected so the arrow keys work as expected.


To configure the tools required, run the following:

```
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get -y install postgresql-client-15
sudo apt  install awscli 
cd ~
wget -O bosh https://github.com/cloudfoundry/bosh-cli/releases/download/v7.3.1/bosh-cli-7.3.1-linux-amd64
chmod +x ./bosh
sudo mv ./bosh /usr/local/bin/bosh
sudo  apt-get install build-essential
sudo snap install ruby --classic
sudo apt-get install -y build-essential zlib1g-dev ruby ruby-dev openssl libxslt1-dev libxml2-dev libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3

```
If prompted for "Daemons using outdated libraries" tab to "Ok" and hit enter/return 
For the unattended upgrade prompt select the only option (spacebar) and tab to Ok and hit enter/return
For "Which services should be restarted?" tab to "Ok" and hit enter/return 

To use the aws cli, Configure the aws cli, make `~\.aws\config` look like:

```
[default]
region = us-gov-west-1

[profile bootstrap]
credential_source = Ec2InstanceMetadata
region = us-gov-west-1
```

### Get the BOSH DB Connection String


On the Session-Manager session, run the following to install the psql client:

```
sudo apt-get install -y postgresql-client
```

For the "Which services should be restarted?" tab to "Ok" and hit enter/return  

Run locally to get the psql statement to connect to the BOSH database:

```
terraform show -json | jq -r ".values.outputs.jumpbox_psql.value"
```

Run locally to get the psql statement to connect to the ProtoBOSH database:

```
terraform show -json | jq -r ".values.outputs.jumpbox_protobosh_psql.value"
```

To bootstrap the databases and extensions (copy each line or block and paste one at a time):

```
\c postgres

create database bosh;
create database bosh_uaadb;
create database credhub;

\c bosh

create extension if not exists "citext";
create extension if not exists "pg_stat_statements";
create extension if not exists "pgcrypto";
create extension if not exists "plpgsql";
create extension if not exists "uuid-ossp";
REVOKE ALL ON SCHEMA public FROM PUBLIC;

\c bosh_uaadb

create extension if not exists "citext";
create extension if not exists "pg_stat_statements";
create extension if not exists "pgcrypto";
create extension if not exists "plpgsql";
create extension if not exists "uuid-ossp";
REVOKE ALL ON SCHEMA public FROM PUBLIC;

\c credhub

create extension if not exists "citext";
create extension if not exists "pg_stat_statements";
create extension if not exists "pgcrypto";
create extension if not exists "plpgsql";
create extension if not exists "uuid-ossp";
REVOKE ALL ON SCHEMA public FROM PUBLIC;

\q
```


### Teardown help


```
aws-vault exec gov-pipeline-admin -- bash

export STACK_NAME=westa-hub
export S3_TFSTATE_BUCKET=westa-hub-terraform-state

terraform apply -var-file="${STACK_NAME}.tfvars" --destroy

aws rds delete-db-snapshot --db-snapshot-identifier final-snapshot-atc-tooling-production
aws rds delete-db-snapshot --db-snapshot-identifier final-snapshot-atc-tooling-staging
aws rds delete-db-snapshot --db-snapshot-identifier final-snapshot-bosh-bosh-westa-hub
aws rds delete-db-snapshot --db-snapshot-identifier final-snapshot-credhub-bosh-credhub-westa-hub
aws rds delete-db-snapshot --db-snapshot-identifier final-snapshot-credhub-tooling-production
aws rds delete-db-snapshot --db-snapshot-identifier final-snapshot-credhub-tooling-staging
aws rds delete-db-snapshot --db-snapshot-identifier final-snapshot-opsuaa-opsuaa-westa-hub
```

A bit is turned on to prevent deletion, to temporarily turn this off modify:

- `terraform/modules/bosh_vpc_v2/network_private.tf` - `prevent_destroy = false`
- `terraform/modules/rds/database.tf` - `prevent_destroy = false`
- `terraform/stacks/westa-hub/buckets.tf` - `log_bucket_force_destroy = true`
- `terraform/stacks/westa-hub/elb_uaa.tf` - `enable_deletion_protection = false`
- `terraform/stacks/westa-hub/stack.tf` - `enable_deletion_protection = false`, `prevent_destroy = false` x2

### Creating the state.yml file from the tfstate file (to be done in your local terminal)

Install the python libraries if you haven't already done so:

Make sure that python3 is installed along with pip3

```
pip3 install pyyaml
```

cd to the westa-hub directory in cg-provision: terraform/stacks/westa-hub

#### Create a script called `tfoutputs-to-yaml.py` with the contents:

```python
#!/usr/bin/env python3

import yaml
import sys
import json


def help():
   print(sys.argv[0]+" filename")
   sys.exit(-1)

if len(sys.argv) != 2:
    help

# Get the command-line arguments, excluding the script name
filename = sys.argv[1:][0]

terraform_outputs_dict = {'terraform_outputs':{}}
terraform_outputs = terraform_outputs_dict['terraform_outputs']
outputs_yaml = open('./state.yml','w')
terraform_outputs_file = open(filename)
json_file = json.load(terraform_outputs_file)    
outputs = json_file['outputs']
for key in outputs:
    terraform_outputs[key] = outputs[key]['value']
yaml.dump(terraform_outputs_dict,outputs_yaml)
outputs_yaml.close()
terraform_outputs_file.close()
```

#### After the state file is created, cp it up to the bucket:

First let's get into a bash shell via aws-vault so it's easier to run the aws commands:

``` 
aws-vault exec gov-pipeline-admin -- bash 

export STACK_NAME=westa-hub
export S3_TFSTATE_BUCKET=westa-hub-terraform-state
```

*Note: the tfstate file is in the terraform.tfstate file, grab a copy from the tfstate s3 bucket*

```
aws s3 cp "s3://${S3_TFSTATE_BUCKET}/${STACK_NAME}/terraform.tfstate" terraform.json --sse AES256
```

Then run the above script as such:

```
python3 tfoutputs-to-yaml.py terraform.json
```

Now copy the resulting state file back to the same bucket:


```
aws s3 cp state.yml "s3://${S3_TFSTATE_BUCKET}/${STACK_NAME}/state.yml" --sse AES256
```


## Creating the protoBOSH

From the jumpbox run:

```
mkdir deploy-protobosh; cd deploy-protobosh
git clone https://github.com/cloud-gov/cg-deploy-bosh.git
git clone https://github.com/cloudfoundry/bosh-deployment.git

export STACK_NAME=westa-hub
export S3_TFSTATE_BUCKET=westa-hub-terraform-state

COMMON_FILE="westa-hub-protobosh.yml"
aws s3 cp "s3://westa-hub-cloud-gov-varz/${COMMON_FILE}" $COMMON_FILE --sse AES256


aws s3 cp "s3://${S3_TFSTATE_BUCKET}/${STACK_NAME}/state.yml" state.yml --sse AES256
bosh int cg-deploy-bosh/variables/terraform-westa-hub.yml -l state.yml > terraform.yml

# The first time we copy westa-hub-protobosh-state.json it will throw errors, this is expected behavior
# continue on
aws s3 cp "s3://westa-hub-cloud-gov-varz/westa-hub-protobosh-state.json" westa-hub-protobosh-state.json --sse AES256 

bosh create-env \
  bosh-deployment/bosh.yml \
  --state=./westa-hub-protobosh-state.json \
  --ops-file bosh-deployment/aws/cpi.yml \
  --ops-file bosh-deployment/aws/iam-instance-profile.yml \
  --ops-file bosh-deployment/aws/cli-iam-instance-profile.yml \
  --ops-file bosh-deployment/uaa.yml \
  --ops-file bosh-deployment/credhub.yml \
  --ops-file bosh-deployment/jumpbox-user.yml \
  --ops-file cg-deploy-bosh/operations/cpi-protobosh.yml \
  --ops-file cg-deploy-bosh/operations/encryption.yml \
  --ops-file cg-deploy-bosh/operations/masterbosh-ntp.yml \
  --ops-file cg-deploy-bosh/operations/external-db-protobosh.yml \
  --ops-file cg-deploy-bosh/operations/s3-blobstore-protobosh.yml \
  --ops-file cg-deploy-bosh/operations/ca.yml \
  --ops-file cg-deploy-bosh/operations/use-c5-large.yml \
  -v director_name=westa-hub-protobosh \
  --vars-file ./state.yml \
  --vars-file ./terraform.yml \
  --vars-file ./westa-hub-protobosh.yml \
  --vars-store=./creds.yml
```

Once completed, be sure to upload the bosh state file back to s3:

```
aws s3 cp westa-hub-protobosh-state.json "s3://westa-hub-cloud-gov-varz/westa-hub-protobosh-state.json" --sse AES256
```

Note to future self: you can generate the contents of vars-file `westa-hub-protobosh.yml` by running the create-env as a `bosh int ...`, the output will go into `creds.yml`.  Copy the contents of `creds.yml` and write it to `westa-hub-protobosh.yml`, upload this to the s3 bucket and then wipe the contents of `creds.yml` before running the `bosh create-env`

### Logging into protoBOSH

Grab a copy of the `login-protobosh.rc` which you can then source with `source login-protobosh.rc`:

```
cd
aws s3 cp "s3://westa-hub-cloud-gov-varz/login-protobosh.rc" login-protobosh.rc  --sse AES256
source login-protobosh.rc
```


#### Upload a stemcell

```
bosh -e westa-hub-protobosh upload-stemcell --sha1 2e113e50c47df57bfe9fe31a0d2bee3fab20af37 \
  https://bosh.io/d/stemcells/bosh-aws-xen-hvm-ubuntu-jammy-go_agent?v=1.181
```

### To configure cloud config

On the jumpbox run:

```
mkdir create-cloud-config; cd create-cloud-config
git clone https://github.com/cloud-gov/cg-deploy-bosh.git
cd cg-deploy-bosh/cloud-config
ls base.yml  # Verify it exists
ls protobosh.yml # Verify it exists

export STACK_NAME=westa-hub
export S3_TFSTATE_BUCKET=westa-hub-terraform-state
aws s3 cp "s3://${S3_TFSTATE_BUCKET}/${STACK_NAME}/state.yml" state.yml --sse AES256
bosh -e westa-hub-protobosh update-cloud-config base.yml -o protobosh.yml --vars-file state.yml

```

### To Upload the BOSH DNS Runtime Config

From the jumpbox run:

```
cd
mkdir deploy_rc; cd deploy_rc
git clone https://github.com/cloud-gov/cg-deploy-bosh.git
git clone https://github.com/cloudfoundry/bosh-deployment.git


bosh -n update-runtime-config --name dns \
  bosh-deployment/runtime-configs/dns.yml \
  --ops-file cg-deploy-bosh/operations/dns-aliases.yml
```

## Creating ToolingBOSH

On the jumpbox run:

```
cd
mkdir deploy-tooling; cd deploy-tooling

git clone https://github.com/cloud-gov/cg-deploy-bosh.git
git clone https://github.com/cloudfoundry/bosh-deployment.git
export STACK_NAME=westa-hub
export S3_TFSTATE_BUCKET=westa-hub-terraform-state
aws s3 cp "s3://${S3_TFSTATE_BUCKET}/${STACK_NAME}/state.yml" state.yml --sse AES256


COMMON_FILE="westa-hub-protobosh.yml"
aws s3 cp "s3://westa-hub-cloud-gov-varz/${COMMON_FILE}" $COMMON_FILE --sse AES256

bosh interpolate cg-deploy-bosh/variables/terraform.yml -l state.yml > terraform.yml

bosh deploy -d toolingbosh bosh-deployment/bosh.yml \
 -o bosh-deployment/uaa.yml \
 -o bosh-deployment/credhub.yml \
 -o bosh-deployment/aws/cpi.yml \
 -o bosh-deployment/aws/iam-instance-profile.yml \
 -o cg-deploy-bosh/operations/name.yml \
 -o cg-deploy-bosh/operations/s3-blobstore.yml \
 -o cg-deploy-bosh/operations/external-db-bosh-rds.yml \
 -o cg-deploy-bosh/operations/uaa-clients.yml \
 -o cg-deploy-bosh/operations/cloud-config.yml \
 -o cg-deploy-bosh/operations/use-z3.yml \
 -o cg-deploy-bosh/operations/update.yml \
 -o cg-deploy-bosh/operations/cron.yml \
 -o cg-deploy-bosh/operations/cpi.yml \
 -o cg-deploy-bosh/operations/dns.yml \
 -o cg-deploy-bosh/operations/nist-ntp.yml \
 -o cg-deploy-bosh/operations/name.yml \
 -l cg-deploy-bosh/variables/westa-hub-tooling.yml \
 -l state.yml \
 -v default_key_name=westa-hub \
 -l terraform.yml 
 
 ```

### Logging into toolingBOSH

Login to Protobosh: `source ~/login-protobosh.rc`
Then download the director_ssl.ca cert: `bosh -d toolingbosh scp bosh:/var/vcap/jobs/director/config/uaa_server_ca.cert director_ssl.ca`

Grab a copy of the `login-bosh.rc` which you can then source with `source login-bosh.rc`:

```
cd
aws s3 cp "s3://westa-hub-cloud-gov-varz/login-bosh.rc" login-bosh.rc  --sse AES256
```

### Create Runtime config for toolingbosh
```
cd
source login-bosh.rc
mkdir deploy_rc; cd deploy_rc
git clone https://github.com/cloud-gov/cg-deploy-bosh.git
git clone https://github.com/cloudfoundry/bosh-deployment.git
bosh -n update-runtime-config --name dns \
  bosh-deployment/runtime-configs/dns.yml \
  --ops-file cg-deploy-bosh/operations/dns-aliases.yml
```
### To configure cloud config for toolingbosh

Locally run terraform init and apply:


On the jumpbox run:

```
mkdir create-tooling-cloud-config; cd create-tooling-cloud-config
git clone https://github.com/cloud-gov/cg-deploy-bosh.git
cd cg-deploy-bosh/cloud-config
ls base.yml  # Verify it exists
ls hub-tooling.yml # Verify it exists

export STACK_NAME=westa-hub
export S3_TFSTATE_BUCKET=westa-hub-terraform-state
aws s3 cp "s3://${S3_TFSTATE_BUCKET}/${STACK_NAME}/state.yml" state.yml --sse AES256
bosh -e westa-hub-protobosh update-cloud-config base.yml -o hub-tooling.yml --vars-file state.yml

```

