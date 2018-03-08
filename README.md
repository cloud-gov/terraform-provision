# cg-provision

Scripts, configurations, and procedures for provisioning the infrastructure to set up cloud.gov.

**Install these first on your laptop:**
* git
* [Terraform](https://www.terraform.io/)
* the [AWS Command Line Interface (CLI) tool](https://aws.amazon.com/cli/)
*  [`jq`, a command line JSON processor](https://stedolan.github.io/jq/)
* the [bosh cli](https://bosh.io/docs/cli-v2.html)

macOS users can install all of these with [`homebrew`](https://brew.sh/).

## Bootstrap procedure

Follow this procedure to setup a bootstrap instance of concourse and deploy minimal components to bring up a permanant instance of concourse deployed by a bosh director.

1. Clone this repository: `git clone https://github.com/18F/cg-provision`
1. Get the rest of the necessary repositories: `./cg-provision/scripts/bootstrap/setup-bootstrap.sh`
1. `cd cg-provision`
1. Make a copy of `env.example.sh` and populate with AWS credentials, etc. (`cp env.example.sh env.sh`)
    1. An example `TERRAFORM_PROVISION_CREDENTIALS_FILE` can be found in `ci/credentials.example.yml`. Make a copy and place in your `${WORKSPACE_DIR}` from `env.sh`.
    1. `toolingbosh` and `concourse` currently need [pre-populated, encrypted secrets files](https://docs.cloud.gov/ops/updating-cf/#updating-secrets-yml): `tooling-bosh-main.yml`,`tooling-bosh-external.yml`,`concourse-tooling-prod.yml`.
        1. Populate these and encrypt with `../cg-scripts/encrypt.sh`, upload to `${VARZ_BUCKET}` with the aws cli, and set the respective passphrases in `env.sh`.
        1. **TODO: generate all secrets for bosh & concourse / pull values from tf.**
    1. `source env.sh`
    1. If the above step fails, you may have to comment out the `TF_STATE_BUCKET` line.
1. Create bootstrap terraform stack: `./scripts/bootstrap/01-bootstrap-terraform.sh`
    1. Note the `public_ip` output. This is the address of your bootstrap concourse instance.
1. Deploy a bootstrap concourse instance: `./scripts/bootstrap/02-bootstrap-concourse.sh`
    1. If, for some reason, this fails, and you want to start this step over, you can use the `./scripts/bootstrap/destroy-02-bootstrap-concourse.sh` script to do this, as there is a volume that persists otherwise.
    1. Login to the web ui at `https://public-ip:4443`, `bootstrap`/password in `${WORKSPACE_DIR}/bootstrap-concourse-creds.yml`.
    1. If you commented out `TF_STATE_BUCKET` above:
        1. Create the `${WORKSPACE_DIR}/cg-provision.yml` file, if you haven't already.
        1. uncomment it and `source env.sh` again.
1. Deploy main terraform: `./scripts/bootstrap/03-main-terraform.sh`
    1. Inspect the terraform plan, then run `terraform-provision/bootstrap-tooling` from the web ui.
    1. If you don't have a `star-fr-cloud-gov` certificate in the account, [upload it to aws](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_server-certs.html#upload-server-certificate).
    1. The `init-bosh-db` task will fail because we haven't setup peering yet.
1. Update [cloud.gov DNS records](https://cloud.gov/docs/ops/dns/) for the `tooling-bosh-uaa` and `tooling-Concourse` ELBs created by terraform.
    1. Eventually you'll need to update records for all newly created ELBs.
    1. **TODO: automate DNS updates**
1. Setup peering between bootstrap and main tooling: `./scripts/bootstrap/04-bootstrap-terraform-peering.sh`
    1. If terraform fails with `InvalidGroup.NotFound: You have specified two resources that belong to different networks`, re-run the bootstrap job. Peering isn't consistently complete before security groups across VPCs are added.
    1. Run `terraform-provision/bootstrap-tooling` again to run `init-bosh-db'.
    1. Run the development, or staging and production plan and bootstrap jobs.
        1. `init-bosh-db` and `init-cf-db` will fail. This is fine, you'll run again in main concourse.
1. Generate secrets for bosh and concourse: `./scripts/bootstrap/05-generate-secrets.sh`
1. Deploy master bosh: `./scripts/bootstrap/06-deploy-bosh.sh`
    1. Upload custom bosh releases to `${BOSH_RELEASES_BUCKET}` with aws cli.
        1. **TODO: bootstrap custom bosh releases**
    1. Run `deploy-bosh/common-releases-master` and `deploy-bosh/deploy-tooling-bosh`
1. Deploy permanent concourse: `./scripts/bootstrap/07-deploy-concourse.sh`
    1. Verify main concourse comes up.
1. Teardown bootstrap concourse and terraform stack: `./scripts/bootstrap/teardown.sh`
1. From the permanent concourse: Fly `cg-provision/ci/pipeline.yml` with the `cg-provision` credentials file you created earlier as `terraform-provision`
    1. Select and unpause the `terraform-provision` pipeline in the UI.
    1. Run the `plan-bootstrap-tooling` job and verify there are no changes.
    1. Run the development, or staging and production plan and bootstrap jobs and verify they complete successfully.
1. Iteratively stand up the rest of the infrastructure in the same way, starting with `cg-deploy-bosh` and continuing with additional Concourse pipelines as necessary in the appropriate [`cg-` GitHub repositories](https://github.com/18F?utf8=%E2%9C%93&query=cg-):
    1. Update secrets for the environment and encrypt/upload to secrets bucket.
    1. Update and upload the concourse pipeline credentials.
    1. Fly the pipeline.
    1. Verify the pipeline runs successfully.

## Teardown procedure
1. Delete all deployments managed by bosh: (development or staging and production, tooling, master)
    1. Run `bosh -d ${deployment_name} delete-deployment` for all deployments in `bosh deployments`
1. Bring up a bootstrap concourse instance as described above:
    1. Run `01-bootstrap-terraform.sh`, `02-bootstrap-concourse.sh`, `03-main-terraform.sh`
    1. If your bootstrap concourse already has peering to tooling VPC, run `01-bootstrap-terraform.sh` again to disable.
1. From the web UI in your bootstrap concourse, run `terraform-provision/destroy-*` for development, or staging and production.
1. Run `destroy-tooling` in the `terraform-provision` pipeline.
1. Teardown bootstrap concourse and terraform stack: `./scripts/bootstrap/teardown.sh`
1. Delete the `${TF_STATE_BUCKET}`, `${VARS_BUCKET}`, `${SEMVER_BUCKET}`, and `${BOSH_RELEASES_BLOBSTORE_BUCKET}` through the AWS console.

## Validating `terraform plan` locally (beta)

* Locally clone git@github.com:18F/cg-pipeline-tasks.git; you'll need `cg-pipeline-tasks/terraform-apply.sh`
* This terraform setup won't use your AWS profile, so export your AWS secret
  key and access key (e.g. w/
  https://github.com/pburkholder/Dotfiles/blob/master/bin/aws_emit)
* Set up a temp directory and get the env vars from, say, the tooling pipeline:
```
export TF_STACK=$(pwd)
mkdir tmp/
cd tmp/

# set env vars from pipeline as `export key=value` for plan parameters
eval "$(fly -t fr get-pipeline -p terraform-provision -j | jq -r '.| .jobs[] | select(.name=="plan-bootstrap-tooling") | .plan[1].params | to_entries[] | "export " + .key + "=" + .value')"

# export your AWS vars, then run:
/your/path/to/cg-pipeline-tasks/terraform-apply.sh

# clean up:
cd .. & rm -rf tmp/
```
