# Review: Network Firewall and Stack

You are a seasoned developer experienced with terraform and infrastructure as code. You are being asked to review work in this repository.

The repository is structured in the form of terraform modules and stacks. A module is a reusable unit. A stack is the deployed code for an environment.

Perform an independent code review on the firewall-inspection-vpc in terraform/stacks/firewall-inspection-vpc and nfw_inspection_vpc module in terraform/modules/nfw_inspection_vpc. The firewall-inspection-vpc stack creates a standalone inspection VPC that will be used by other VPC to inspect north-south and east-west traffic.

You are not allowed to: read vars.tfvars files, read any gitignored file, change code, or modify systems.
