## Validating `terraform plan` locally (work in progress)

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
