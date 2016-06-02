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
1. run `./scripts/bootstrap.sh apply`
1. Login to the Concourse instance URL you see in the output
  1. Select `terraform-provision` pipeline in the menu, unpause if paused
    1. Run the `bootstrap-tooling` job
    1. Once `bootstrap-tooling` is finished, run both `bootstrap-staging` and `bootstrap-production`
    1. Make a note of all the outputs, so you can modify and upload proper concourse
       credentials and manifest secrets for the BOSH pipeline
  1. Select `bootstrap` pipeline in the menu
    1. Run the `setup-vpc-peering` job
  1. Select `deploy-bosh` pipeline in the menu, and unpause if paused
    1. Verify that `deploy-master-bosh` job completes successfully
    1. Verify that `deploy-tooling-bosh` job completes successfully
  1. Select `bootstrap` pipeline in the menu
    1. Run the `teardown-vpc-peering` job
1. run `./scripts/bootstrap.sh destroy`