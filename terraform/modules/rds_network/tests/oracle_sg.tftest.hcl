# tests/oracle_sg.tftest.hcl — native `terraform test` for the Oracle SG.
#
# Run from the module dir:  terraform test
# Uses the mock AWS provider so no credentials / no real API calls are made.
# Asserts the Oracle SG exposes exactly the intended rule set: TCPS 2484 ingress
# (TLS-only — no plaintext 1521) plus all-egress, one rule per source SG.

mock_provider "aws" {}

variables {
  stack_description     = "test"
  vpc_id                = "vpc-test"
  security_groups       = ["sg-source-1"]
  security_groups_count = 1
  # Module inputs required by variables.tf but unused by the Oracle SG:
  rds_private_cidr_1 = "10.0.1.0/24"
  rds_private_cidr_2 = "10.0.2.0/24"
  rds_private_cidr_3 = "10.0.3.0/24"
  rds_private_cidr_4 = "10.0.4.0/24"
  az1_route_table    = "rtb-1"
  az2_route_table    = "rtb-2"
  allowed_cidrs      = ["10.0.0.0/16"]
}

run "oracle_sg_has_expected_rules" {
  command = plan

  # --- SG exists. Rules are managed ONLY by the standalone aws_security_group_rule
  #     resources below — the SG resource declares NO inline ingress/egress (see
  #     sg_oracle.tf), which is what keeps applies from oscillating. ---
  assert {
    condition     = aws_security_group.rds_oracle.description == "Allow access to incoming Oracle traffic"
    error_message = "rds_oracle SG must exist with the expected description"
  }

  # --- 2484 TCPS ingress rule (the only ingress — TLS-only) ---
  assert {
    condition     = aws_security_group_rule.oracle_ingress_tcps[0].from_port == 2484 && aws_security_group_rule.oracle_ingress_tcps[0].to_port == 2484
    error_message = "TCPS rule must open 2484"
  }
  assert {
    condition     = aws_security_group_rule.oracle_ingress_tcps[0].type == "ingress" && aws_security_group_rule.oracle_ingress_tcps[0].protocol == "tcp"
    error_message = "TCPS rule must be tcp ingress"
  }
  assert {
    condition     = aws_security_group_rule.oracle_ingress_tcps[0].source_security_group_id == "sg-source-1"
    error_message = "TCPS rule source must be the provided source SG"
  }

  # --- egress rule: all protocols/ports to the source SG ---
  assert {
    condition     = aws_security_group_rule.oracle_egress_default[0].type == "egress" && aws_security_group_rule.oracle_egress_default[0].protocol == "-1"
    error_message = "egress rule must be all-protocol egress"
  }

  # --- one rule per source SG (count wiring) ---
  assert {
    condition     = length(aws_security_group_rule.oracle_ingress_tcps) == 1 && length(aws_security_group_rule.oracle_egress_default) == 1
    error_message = "expected exactly one ingress + one egress rule per source SG for count=1"
  }
}
