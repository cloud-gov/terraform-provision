# Add a managed environment

Use this to prep a new environment to be managed by our tooling stack.

For the examples below, we'll say we're creating the environment `easta`
basing it on the environment `westa`
(NOTE: your environment name should not end in a number)

### Prep the file
1. First, copy `scripts/add_environment/env.example.sh` to `scripts/add_environment/env.sh`
   (`env.sh` is in the gitignore, so really do this - credential leak fire drills are no fun)
1. Second, fetch the arn of the concourse iaas workers from the tooling account and put it for `TF_VAR_tf_remote_role_arn` in the `env.sh` file
1. Third, fetch the arn of user for iam cert provisioner and put in for `TF_VAR_cert_remote_role_arn` in the `env.sh` file.

### Create the bosh ssh key
1. Generate key with `ssh-keygen -f <env> -C <env>`
1. Put both files into varz bucket under `/keys/` folder

### Run the file
1. `source scripts/add_environment/env.sh`
1. Run `scripts/add_environment/manage_environment.sh` from the root of this repository
1. From the output json file, get the `tf_role_arn` and `cert_role_arn`

### Add new variables in the concourse creds
1. Get the cg-provision.yml file from s3
1. Add these values to the file
```
<env>_assume_arn: <TF ROLE ARN from terraform output>
<env>_parent_assume_arn: <TF REMOTE ROLE ARN from `TF_VAR_tf_remote_role_arn` in env.sh>
<env>_parent_stack_name: tooling
<env>_ssh_key: <value from key.pub>
```
### Add these new vars to your new enivornment concourse
1. `ci/pipeline.yml` duplicate the `plan-bootstrap-westa`, `bootstrap-westa`, `acme-certificate-westa`, and `acme-certificate-westa` jobs
   to `plan-bootstrap-easta`, `bootstrap-easta`, `acme-certificate-easta`, and `acme-certificate-easta`, respectively
1. in the new jobs, edit the names of any variables, tasks, etc to refer to the new environment
```
      TF_VAR_assume_arn: ((<env>_assume_arn))
      TF_VAR_parent_assume_arn: ((<env>_parent_assume_arn))
      TF_VAR_parent_stack_name: ((<env>_parent_stack_name))
      TF_VAR_bosh_default_ssh_public_key: ((<env>_ssh_key))
```
1. get the cg-provision secrets file from the secrets s3 bucket
1. generate new values for all of these. For secrets, such as passwords, use a cryptographic string
   generator. For othe values, try to follow estabilished patterns.
1. for `ASSUME_ROLE_ARN` in `acme-certificate-easta` and `acme-certificate-east-1-apps` (twice in each job),
   use the value from `cert_role_arn` above
1. fly the pipeline:
   `fly -t concourse set-pipeline -p terraform-provision -c ./ci/pipeline.yml -l <path-to-secrets-file>`
1. run `acme-certificate-easta` in concourse
1. run `acme-certificate-easta-apps` in concourse
1. run `plan-bootstrap-easta` in concourse
1. review the plan. Sorry.
1. assuming it looks good, run `bootstrap-easta` in concourse


TODO: same thing for external environments
