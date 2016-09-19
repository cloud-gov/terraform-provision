# cg-provision

Scripts, configurations, and procedures for provisioning the infrastructure to set-up cloud.gov. 

**Install these first on your laptop:**
* [Terraform](https://www.terraform.io/)
* the [AWS Command Line Interface (CLI) tool](https://aws.amazon.com/cli/)
* [`jq`, a command line JSON processor](https://stedolan.github.io/jq/) installed

macOS  users can install all of these with [`homebrew`](http://brew.sh/)

## Procedures

1. Create S3 bucket with versioning enabled to store Terraform state: `terraform-state`
1. Create S3 bucket with versioning enabled to store BOSH releases and metadata: `cloud-gov-bosh-releases`
  1. Upload all custom bosh releases
1. Create S3 bucket to store BOSH stemcell images: `cloud-gov-stemcell-images`
  1. Create IAM user with privileges to create EC2 volumes, snapshots, AMIs, and the `cloud-gov-stemcell-images` bucket
  1. Create [vmimport](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/VMImportPrerequisites.html#vmimport-service-role) role, using `cloud-gov-stemcell-images` bucket in service role
1. Create S3 buckets for bosh blobstores: `bosh-tooling-blobstore`, `bosh-staging-blobstore`, `bosh-prod-blobstore`
1. Create S3 bucket with versioning enabled to store concourse credentials: `concourse-credentials`
  1. Copy `./ci/credentials.yml.example` to `cg-provision.yml`
  1. Fill out `cg-provision.yml` with proper values
  1. Upload `cg-provision.yml` into the concourse credentials bucket
1. Clone [`cg-deploy-bosh` repository](https://github.com/18F/cg-deploy-bosh)
  1. Copy `cg-deploy-bosh/credentials.example.yml` to `cg-deploy-bosh.yml`
  1. Fill `cg-deploy-bosh.yml` as much as you can. (You will need to modify this later)
  1. Upload `cg-deploy-bosh.yml` into the concourse credentials bucket
1. Clone [`cg-deploy-concourse` repository](https://github.com/18F/cg-deploy-concourse)
  1. Copy `cg-deploy-concourse/credentials.example.yml` to `cg-deploy-concourse.yml`
  1. Fill `cg-deploy-concourse.yml` as much as you can (You will need to modify this later)
  1. Upload `cg-deploy-concourse.yml` into the concourse credentials bucket
1. [Upload any IAM server certificates](https://github.com/18F/https#loading-the-cert-into-amazon-web-services)
1. Copy `./scripts/environment.default.sh` to `./scripts/environment.sh` and edit as appropriate
1. Run `./scripts/bootstrap.sh apply`
1. Login to the Concourse instance URL you see in the output
  1. Select `terraform-provision` pipeline in the menu
    1. Unpause the pipeline if paused
    1. Run the `bootstrap-tooling` job
    1. Make a note of all the outputs
      1. Modify the `cg-deploy-bosh.yml` you created earlier, and fill in with proper values from the outputs
      1. Re-upload `cg-deploy-bosh.yml` to the concourse credentials bucket
      1. Modify the `cg-deploy-concourse.yml` you created earlier, and fill in with proper values from the outputs
      1. Re-upload `cg-deploy-concourse.yml` to the concourse credentials bucket
  1. Select `bootstrap` pipeline in the menu
    1. Run the `bootstrap-bosh-pipeline` job
    1. Run the `bootstrap-concourse-pipeline` job
    1. Run the `setup-vpc-peering` job
  1. Select `deploy-bosh` pipeline in the menu
    1. Upload a JSON file called `master-bosh-state.json` with contents of just `{}` to the BOSH manifest secrets bucket
    1. Upload a properly filled and [encrypted secrets file](https://docs.cloud.gov/ops/updating-cf/#updating-secrets-yml) for masterbosh to the BOSH manifest secrets bucket
    1. Upload a [properly encrypted ssh key](https://github.com/18F/cg-pipeline-tasks/blob/master/generate_key.sh) for masterbosh to the BOSH manifest secrets bucket
    1. Unpause the pipeline if paused
    1. Run `deploy-master-bosh` job
    1. Upload a properly filled and [encrypted secrets file](https://docs.cloud.gov/ops/updating-cf/#updating-secrets-yml) for toolingbosh to the BOSH manifest secrets bucket
    1. Upload the CA cert for tooling bosh to the BOSH manifest secrets bucket
    1. Create S3 bucket for tooling bosh blobstore: `bosh-tooling-blobstore`
    1. Run `deploy-tooling-bosh` job
    1. Run `common-releases-tooling` job
  1. Select `deploy-concourse` pipeline in the menu
    1. Upload a properly filled and [encrypted secrets file](https://docs.cloud.gov/ops/updating-cf/#updating-secrets-yml) for staging concourse to the BOSH manifest secrets bucket
    1. Upload a properly filled and [encrypted secrets file](https://docs.cloud.gov/ops/updating-cf/#updating-secrets-yml) for production concourse to the BOSH manifest secrets bucket
    1. Unpause the pipeline if paused
    1. Ensure both `deploy-concourse-staging` and `deploy-concourse-production` jobs run successfully
  1. Select `bootstrap` pipeline in the menu
    1. Run the `teardown-vpc-peering` job
1. Run `./scripts/bootstrap.sh destroy`
1. Login to production concourse
1. Fly `./ci/pipeline.yml` with the `cg-provision.yml` credentials file you created earlier as `terraform-provision`
  1. Select and unpause the `terraform-provision` pipeline in the UI
  1. Run the `bootstrap-tooling` job and verify there are no changes
  1. Run both the `bootstrap-staging` and `bootstrap-production` jobs and verify they complete successfully
1. Iterate the rest of the infrastructure in the same way staring with `cg-deploy-bosh`:
  1. Update secrets for the environment and encrypt/upload to secrets bucket
  1. Update and upload the concourse pipeline credentials
  1. Update the pipeline to use proper stemcell
  1. Fly the pipeline
  1. Verify the pipeline runs successfully
1. After CloudFoundry is successfully deployed, make sure it has a `security-group` called `internal_access` that includes any private subnets within that installation that tenant applications should be able to access, e.g.

 ```
 [
    {
      "destination": "10.0.50.0-10.0.51.255",
      "protocol": "all"
    }
 ]
```

  # Monitoring
  1. Create a Route 53 name for metrics.environment.cloud.gov
  1. Create an ELB to point to the 0.riemann.monitoring.monitoring-environment.bosh
  1. Point Route 53 name to ELB for HTTPS
  1. Create a security group to allow access to port 3000 for Grafana

