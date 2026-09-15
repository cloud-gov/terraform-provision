# AWS Network Firewall Inspection VPC

The module creates an inspection VPC but does not connect it to any spoke VPCs. This is left to the bosh_vpc module. The inspection VPC is only intended to inspect egress traffic. Egress includes east-west or egress from one VPC to another VPC.

According the AWS, ingress inspection typically is not in scope for the network firewall. WAF, security groups, and NACLs are the preferred method of securing ingress traffic.

## Default Firewall Behavior

Given this will be applied to existing VPCs, the default firewall behavior is to not block anything.
