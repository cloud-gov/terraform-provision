# Bootstrap procedure

Follow this procedure to setup a bootstrap instance of concourse and deploy minimal components to bring up a permanant instance of concourse deployed by a bosh director.

1. Clone this repository: `git clone https://github.com/cloud-gov/cg-provision`
1. Get the rest of the necessary repositories: `./cg-provision/scripts/bootstrap/setup-bootstrap.sh`
1. `cd cg-provision`
1. Make a copy of `env.example.sh` and populate with AWS credentials, etc. (`cp env.example.sh env.sh`)
    1. An example `TERRAFORM_PROVISION_CREDENTIALS_FILE` can be found in `ci/credentials.example.yml`. Make a copy and place in your `${WORKSPACE_DIR}` from `env.sh`.
    1. `toolingbosh` and `concourse` currently need [pre-populated, encrypted secrets files](https://docs.cloud.gov/ops/updating-cf/#updating-secrets-yml): `tooling-bosh-main.yml`,`tooling-bosh-external.yml`,`concourse-tooling-prod.yml`.
        1. Populate these and encrypt with `../cg-pipeline-tasks/encrypt.sh`, upload to `${VARZ_BUCKET}` with the aws cli, and set the respective passphrases in `env.sh`.
        1. **TODO: generate all secrets for bosh & concourse / pull values from tf.**
    1. `source env.sh`
    1. If the above step fails, you may have to comment out the `TF_STATE_BUCKET` line.
1. Create bootstrap terraform stack: `./scripts/bootstrap/01-bootstrap-terraform.sh`
    1. Note the `public_ip` output. This is the address of your bootstrap concourse instance.
1. Make sure you are on the GSA network, either via VPN, or being in a GSA office.
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
    1. Look at the DNS names of these ELBs in the AWS console and plug those into https://github.com/18F/cg-provision/blob/master/terraform/stacks/dns/stack.tf  For the new dev env, you can edit the entries that have `dev2` in the name.  Be sure to leave the `dualstack.` on the front of the A record.
    1. Eventually you'll need to update records for all newly created ELBs.
    1. **TODO: automate DNS updates**
1. Setup peering between bootstrap and main tooling: `./scripts/bootstrap/04-bootstrap-terraform-peering.sh`
    1. If terraform fails with `InvalidGroup.NotFound: You have specified two resources that belong to different networks`, re-run the bootstrap job. Peering isn't consistently complete before security groups across VPCs are added.
    1. Run `terraform-provision/bootstrap-tooling` again to run `init-bosh-db`.
    1. Run the development, or staging and produ to
          address your specific situation.ction plan and bootstrap jobs.
        1. `init-bosh-db` and `init-cf-db` will fail. This is fine, you'll run again in main concourse.
1. Generate secrets for bosh and concourse: `./scripts/bootstrap/05-generate-secrets.sh`
1. Deploy master bosh: `./scripts/bootstrap/06-deploy-bosh.sh`
    1. Upload custom bosh releases to `${BOSH_RELEASES_BUCKET}` with aws cli.  Get the latest release of each type from `cloud-gov-bosh-releases` if you are building out a dev environment.
        1. **TODO: bootstrap custom bosh releases**
        1. This might help:
            ```aws s3 ls cloud-gov-bosh-releases > /tmp/releases.out
            mkdir -p /tmp/releases
            awk '/-[0-9]*.tgz$/ {print $4}' /tmp/releases.out | \
                sed 's/\(.*\)-[0-9.]*.tgz/\1/' | \
                sort -u | \
                while read line ; do
                    sort -n /tmp/releases.out | \
                    awk '{print $4}' | egrep "^${line}.*tgz" | \
                    tail -1
                done | \
                while read release ; do
                    echo aws s3 cp s3://cloud-gov-bosh-releases/"${release}" /tmp/releases/
                done
            <set up your AWS creds for the new account>
            aws s3 sync /tmp/releases s3://cloud-gov-bosh-releases-dev --sse AES256
            ```
    1. Run `deploy-bosh/common-releases-master` and `deploy-bosh/deploy-tooling-bosh`
    1. If you get a "x509: certificate signed by unknown authority" error, you will need to add the root CA cert generated to the `tmp/concourse-environment.yml` file in the `common_ca_cert_store` section.  You can get the root cert by looking at `echo "" |openssl s_client -connect opslogin.<domain>:443 -showcerts`.  After you add it, rerun the 06 deploy script.
1. Deploy permanent concourse: `./scripts/bootstrap/07-deploy-concourse.sh`
    1. Verify main concourse comes up.
    1. The hostname can be found in `terraform/stacks/dns/stack.tf` Search for: `cloud_gov_ci_dev2_cloud_gov_a` in there for the dev env, for example.
    1. The username/pw can be found by getting the `CONCOURSE_SECRETS_PASSPHRASE` from `env.sh` and using it like so:
        ```aws s3 cp s3://${VARZ_BUCKET}/concourse-tooling-prod.yml /tmp/
        INPUT_FILE=/tmp/concourse-tooling-prod.yml OUTPUT_FILE=/tmp/concourse-tooling-prod-decrypted.yml PASSPHRASE=XXX ../cg-pipeline-tasks/decrypt.sh
        grep basic_auth /tmp/concourse-tooling-prod-decrypted.yml
        rm /tmp/concourse-tooling-prod-decrypted.yml /tmp/concourse-tooling-prod.yml
        ```
1. Teardown bootstrap and terraform stack: `./scripts/bootstrap/teardown.sh`
1. From the permanent concourse: Fly `cg-provision/ci/pipeline.yml` with the credentials you used to log into the concourse UI above.
    1. `fly --target TARGET login --concourse-url=https://HOSTNAME/ --ca-cert tmp/realconcourse-cacrt.pem --username USERNAME --password XXX`
    1. `fly -t TARGET set-pipeline -p terraform-provision -c ci/pipeline<maybe -development>.yml -l ci/concourse-defaults.yml -l tmp/cg-provision.yml`
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
1. Delete the `${TF_STATE_BUCKET}`, `${VARZ_BUCKET}`, `${SEMVER_BUCKET}`, and `${BOSH_RELEASES_BLOBSTORE_BUCKET}` through the AWS console.

