#!/bin/bash -e

prefix='smatyukevich-'
ACCESS_KEY_ID=$(cat ~/.aws/credentials | grep aws_access_key_id | awk '{print $3}')
SECRET_ACCESS_KEY=$(cat ~/.aws/credentials | grep aws_secret_access_key | awk '{print $3}')
ACCOUNT_ID=$(aws ec2 describe-security-groups --group-names "Default" --query "SecurityGroups[].OwnerId" --output text)
AWS_REGION=$(cat ~/.aws/config | grep region | awk '{print $3}')
AVZ1=$(aws ec2 describe-availability-zones --query "AvailabilityZones[0].ZoneName" --output text)
AVZ2=$(aws ec2 describe-availability-zones --query "AvailabilityZones[1].ZoneName" --output text)




terrafrom_state="${prefix}terraform-state"
cloud_gov_varz="${prefix}cloud-gov-varz"
cloud_gov_varz_staging="${prefix}cloud-gov-varz-staging"
cloud_gov_bosh_releases="${prefix}cloud-gov-bosh-releases"
cloud_gov_stemcell_images="${prefix}cloud-gov-stemcell-images"
aws s3api create-bucket --acl private  --bucket $terrafrom_state --region $AWS_REGION --create-bucket-configuration LocationConstraint=$AWS_REGION
aws s3api put-bucket-versioning --bucket $terrafrom_state --versioning-configuration Status=Enabled
aws s3api create-bucket --acl private  --bucket $cloud_gov_varz --region $AWS_REGION --create-bucket-configuration LocationConstraint=$AWS_REGION
aws s3api put-bucket-versioning --bucket $cloud_gov_varz --versioning-configuration Status=Enabled
aws s3api create-bucket --acl private  --bucket $cloud_gov_varz_staging --region $AWS_REGION --create-bucket-configuration LocationConstraint=$AWS_REGION
aws s3api put-bucket-versioning --bucket $cloud_gov_varz_staging --versioning-configuration Status=Enabled
aws s3api create-bucket --acl private  --bucket $cloud_gov_bosh_releases --region $AWS_REGION --create-bucket-configuration LocationConstraint=$AWS_REGION
aws s3api put-bucket-versioning --bucket $cloud_gov_bosh_releases --versioning-configuration Status=Enabled
aws s3api create-bucket --acl private  --bucket $cloud_gov_stemcell_images --region $AWS_REGION --create-bucket-configuration LocationConstraint=$AWS_REGION
aws s3api put-bucket-versioning --bucket $cloud_gov_stemcell_images --versioning-configuration Status=Enabled

cat > cloud_gov_policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:*"],
      "Resource": ["arn:aws:s3:::$cloud_gov_stemcell_images"]
    },
    {
      "Effect": "Allow",
      "Action": [
         "ec2:CreateImage",
         "ec2:CreateSnapshot",
         "ec2:CreateVolume"
      ],
      "Resource": ["*"]
    }
  ]
}
EOF
aws iam create-user --user-name cloud_gov
aws iam put-user-policy --user-name cloud_gov --policy-name cloud_gov_policy --policy-document file://cloud_gov_policy.json

cat > vmimport.json <<EOF
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Sid":"",
         "Effect":"Allow",
         "Principal":{
            "Service":"vmie.amazonaws.com"
         },
         "Action":"sts:AssumeRole",
         "Condition":{
            "StringEquals":{
               "sts:ExternalId":"vmimport"
            }
         }
      }
   ]
}
EOF
aws iam create-role --role-name vmimport --assume-role-policy-document file://vmimport.json

bosh_init_blobstore="${prefix}bosh-init-blobstore"
bosh_tooling_blobstore="${prefix}bosh-tooling-blobstore"
bosh_staging_blobstore="${prefix}bosh-staging-blobstore"
bosh_prod_blobstore="${prefix}bosh-prod-blobstore"
concourse_credentials="${prefix}concourse-credentials"
aws s3api create-bucket --acl private  --bucket $bosh_init_blobstore --region $AWS_REGION --create-bucket-configuration LocationConstraint=$AWS_REGION
aws s3api create-bucket --acl private  --bucket $bosh_tooling_blobstore --region $AWS_REGION --create-bucket-configuration LocationConstraint=$AWS_REGION
aws s3api create-bucket --acl private  --bucket $bosh_staging_blobstore --region $AWS_REGION --create-bucket-configuration LocationConstraint=$AWS_REGION
aws s3api create-bucket --acl private  --bucket $bosh_prod_blobstore --region $AWS_REGION --create-bucket-configuration LocationConstraint=$AWS_REGION
aws s3api create-bucket --acl private  --bucket $concourse_credentials --region $AWS_REGION --create-bucket-configuration LocationConstraint=$AWS_REGION
aws s3api put-bucket-versioning --bucket $concourse_credentials --versioning-configuration Status=Enabled

gen_password ()
{
  tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1
}

cat > cg-provision.yml <<EOF
aws_access_key_id: $ACCESS_KEY_ID
aws_secret_access_key: $SECRET_ACCESS_KEY
aws_account_id: $ACCOUNT_ID
aws_partition: aws
aws_default_region: $AWS_REGION
aws_s3_tfstate_bucket: $terrafrom_state
staging_private_bucket: $cloud_gov_varz_staging
prod_private_bucket: $cloud_gov_varz
bosh_releases_bucket: $cloud_gov_bosh_releases
bosh_stemcells_bucket: $cloud_gov_stemcell_images
aws_az1: $AVZ1 
aws_az2: $AVZ2
tooling_vpc_cidr: 10.0.0.0/16
tooling_public_cidr_1: 10.0.3.0/24
tooling_public_cidr_2: 10.0.4.0/24
tooling_private_cidr_1: 10.0.1.0/24
tooling_private_cidr_2: 10.0.2.0/24
tooling_rds_private_cidr_1: 10.0.5.0/24
tooling_rds_private_cidr_2: 10.0.6.0/24
tooling_rds_password: $(gen_password)
tooling_restricted_ingress_web_cidrs: "127.0.0.1/32,192.168.0.1/24"
concourse_prod_rds_password: $(gen_password)
concourse_prod_cidr: 10.0.7.0/24
concourse_staging_rds_password: $(gen_password)
concourse_staging_cidr: 10.0.8.0/24
staging_vpc_cidr: 10.2.0.0/16
staging_public_cidr_1: 10.2.3.0/24
staging_public_cidr_2: 10.2.4.0/24
staging_private_cidr_1: 10.2.1.0/24
staging_private_cidr_2: 10.2.2.0/24
staging_rds_private_cidr_1: 10.2.5.0/24
staging_rds_private_cidr_2: 10.2.6.0/24
staging_services_cidr_1: 10.2.30.0/24
staging_services_cidr_2: 10.2.31.0/24
staging_rds_password: $(gen_password)
staging_cf_rds_password: $(gen_password)
staging_restricted_ingress_web_cidrs: "127.0.0.1/32,192.168.0.1/24"
production_vpc_cidr: 10.1.0.0/16
production_public_cidr_1: 10.1.3.0/24
production_public_cidr_2: 10.1.4.0/24
production_private_cidr_1: 10.1.1.0/24
production_private_cidr_2: 10.1.2.0/24
production_services_cidr_1: 10.1.30.0/24
production_services_cidr_2: 10.1.31.0/24
production_rds_private_cidr_1: 10.1.5.0/24
production_rds_private_cidr_2: 10.1.6.0/24
production_rds_password: $(gen_password)
production_cf_rds_password: $(gen_password)
production_restricted_ingress_web_cidrs: "127.0.0.1/32,192.168.0.1/24"
nat_gateway_ami: "ami-004b0f60"
EOF
aws s3 cp cg-provision.yml s3://${concourse_credentials}/ 


vpc_id=$(aws ec2  describe-vpcs --filters Name=isDefault,Values=true --query Vpcs[0].VpcId --output text)
vpc_cidr=$(aws ec2  describe-vpcs --filters Name=isDefault,Values=true --query Vpcs[0].CidrBlock --output text)
route_table_id=$(aws ec2 describe-route-tables --filters Name=vpc-id,Values=$vpc_id --query RouteTables[0].RouteTableId --output text)


cat > scripts/environment.sh <<EOF
export TF_VAR_remote_state_bucket=$terrafrom_state
export TF_VAR_account_id=$ACCOUNT_ID
export AWS_ACCESS_KEY_ID=$ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION=$AWS_REGION
export TF_VAR_az1=$AVZ1
export TF_VAR_az2=$AVZ2
export TF_VAR_aws_access_key_id=$ACCESS_KEY_ID
export TF_VAR_aws_secret_access_key=$SECRET_ACCESS_KEY
export TF_VAR_aws_default_region=$AWS_REGION
export TF_VAR_default_vpc_id=$vpc_id
export TF_VAR_default_vpc_cidr=$vpc_cidr
export TF_VAR_default_vpc_route_table=$route_table_id
export TF_VAR_credentials_bucket=$concourse_credentials
export TF_VAR_ami_id='ami-72723412'
export TF_VAR_concourse_password="$(gen_password)"
EOF

./scripts/bootstrap.sh apply

cat > cg-deploy-bosh.yml <<EOF
production-bucket-name: $cloud_gov_varz
production-bucket-access-key-id: $ACCESS_KEY_ID
production-bucket-secret-access-key: $SECRET_ACCESS_KEY
bosh-init-bucket-name: SECURE_BUCKET_BOSH_INIT
bosh-init-bucket-access-key-id: $ACCESS_KEY_ID
bosh-init-bucket-secret-access-key: $SECRET_ACCESS_KEY
bosh-init-bucket-region: $AWS_REGION
masterbosh-secrets-passphrase: passphrase0
tooling-secrets-passphrase: passphrase1
staging-secrets-passphrase: passphrase2
prod-secrets-passphrase: passphrase3
masterbosh-target: 192.0.2.23
masterbosh-username: admin
masterbosh-password: password
toolingbosh-target: 192.0.2.23
toolingbosh-username: admin
toolingbosh-password: SECRET
slack-webhook-url: https://hooks.slack.com/services/XXXX/XXX/XXXX
slack-channel: '#CHANNEL'
slack-username: concourse
slack-icon-url: http://cl.ly/image/3e1h0H3H2s0P/concourse-logo.png
s3-bosh-releases-bucket: RELEASES_BUCKET
s3-bosh-releases-access-key-id: AWS_ACCESS_KEY_ID
s3-bosh-releases-secret-access-key: AWS_SECRET_ACCESS_KEY
stagingbosh-username: admin
stagingbosh-password: password
stagingbosh-target: 192.0.2.23
productionbosh-username: admin
productionbosh-password: password
productionbosh-target: 192.0.2.23
staging-bucket-name: SECURE_BUCKET_STAGING

EOF
