bosh create-env ../concourse-deployment/lite/concourse.yml \
  --state bootstrap-concourse-state.json \
  --vars-store bootstrap-concourse-creds.yml \
  -o ../concourse-deployment/lite/infrastructures/aws.yml \
  -o ./bosh/opsfiles/basic-auth.yml \
  -o ./bosh/opsfiles/self-signed-tls.yml \
  -l ../concourse-deployment/versions.yml \
