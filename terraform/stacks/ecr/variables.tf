variable "remote_state_bucket" {
}

variable "tooling_stack_name" {
}

variable "repositories" {
  type = set(string)
  default = [
    "bosh-deployment-resource",
    "bosh-io-release-resource",
    "bosh-io-stemcell-resource",
    "cf-cli-resource",
    "cf-resource",
    "cloud-service-broker",
    "concourse-http-jq-resource",
    "concourse-task",
    "cron-resource",
    "csb",
    "email-resource",
    "external-domain-broker-testing",
    "external-domain-broker-migrator-testing",
    "general-task",
    "git-resource",
    "github-pr-resource",
    "github-release-resource",
    "legacy-domain-certificate-renewer-testing",
    "oci-build-task",
    "openresty",
    "pages-dind",
    "pages-dind-v25",
    "pages-nginx-v1",
    "pages-node-v20",
    "pages-postgres-v15",
    "pages-python-v3.11",
    "pages-redis-v7.2",
    "pages-zap",
    "playwright-python",
    "pool-resource",
    "pulledpork",
    "registry-image-resource",
    "s3-resource",
    "s3-simple-resource",
    "semver-resource",
    "slack-notification-resource",
    "opensearch-testing",
    "opensearch-dashboards-testing",
    "time-resource",
    "ubuntu-hardened",
  ]
}
