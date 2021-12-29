# Add a managed environment

Use this to prep a new environment to be managed by our tooling stack.

For the examples below, we'll say we're creating the environment `east1`
basing it on the environment `west1`

1. First, fetch the arn of the concourse iaas workers from the tooling account.
1. For the rest of the instructions, make sure you're in the repo root
1. Next, copy `scripts/add_environment/env.example.sh` to `scripts/add_environment/env.sh`
   (`env.sh` is in the gitignore, so really do this - credential leak fire drills are no fun)
1. Modify `scripts/add_environment/env.sh` to have the correct values for the new account
1. `source scripts/add_environment/env.sh`
1. Run `scripts/add_environment/manage_environment.sh` from the root of this repository
1. From the output json file, get the `tf_role_arn` and `cert_role_arn`
1. `ci/pipeline.yml` duplicate the `plan-bootstrap-west1`, `bootstrap-west1`, `acme-certificate-west1`, and `acme-certificate-west1` jobs
   to `plan-bootstrap-east1`, `bootstrap-east1`, `acme-certificate-east1`, and `acme-certificate-east1`, respectively
1. in the new jobs, edit the names of any variables, tasks, etc to refer to the new environment
1. get the cg-provision secrets file from the secrets s3 bucket
1. generate new values for all of these. For secrets, such as passwords, use a cryptographic string
   generator. For othe values, try to follow estabilished patterns.
1. for `TF_VAR_assume_arn` in `plan-bootstrap-east1`, use the value from `tf_role_arn` above
1. for `ASSUME_ROLE_ARN` in `acme-certificate-east1` and `acme-certificate-east-1-apps` (twice in each job),
   use the value from `cert_role_arn` above
1. fly the pipeline:
   `fly -t concourse set-pipeline -p terraform-provision -c ./ci/pipeline.yml -l <path-to-secrets-file>`
1. run `acme-certificate-east1` in concourse
1. run `acme-certificate-east1-apps` in concourse
1. run `plan-bootstrap-east1` in concourse
1. review the plan. Sorry.
1. assuming it looks good, run `bootstrap-east1` in concourse


TODO: same thing for external environments