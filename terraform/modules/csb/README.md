# Module CSB

Resources related to the Cloud Service Broker.

See also https://github.com/cloud-gov/csb.

## Why two modules?

The `iam` module contains the IAM policy that the broker uses to deploy resources on behalf of customers. This is distinct from the IAM policy in the `broker` module used by Cloud Foundry to pull the CSB image. Some brokerpaks must create resources in AWS Commercial, so both a Commercial and a GovCloud IAM user must be created. They are managed in a separate module for the following reasons:

- To support deploying them to two separate partitions using two providers, without forcing the rest of the broker resources to specify `provider=`, since they will only ever be deployed to GovCloud.
- To keep the policies together in the codebase, since they are related. (We could have split up the CSB resources by GovCloud vs Commercial, but the brokerpak-related policies would no longer all be in one place.)
- To maintain a dedicated space for the policies, which are expected to grow as we add more brokerpaks.
