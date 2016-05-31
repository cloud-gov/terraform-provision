# cg-provision
Scripts and configuration for provisioning infrastructure used in cloud.gov

Manual steps to create the world:

1. Make sure you have terraform installed
1. Copy `scripts/environment.default.sh` to `scripts/environment.sh` and edit
1. Create S3 bucket with versioning enabled to store terraform state
1. Create S3 bucket with versioning enabled to store concourse credentials
 1. Fill out a copy of `ci/credentials.yml.example`
 1. Upload as `cg-provision.yml` into the concourse credentials bucket
1. Create S3 bucket with versioning enabled to store bosh manifest secrets
1. Upload any IAM server certificates
1. run `./scripts/bootstrap.sh`
1. Login to the Concourse instance URL you see in the output and start the world
