data "aws_iam_policy_document" "aws_broker_policy" {
  statement {
    actions = [
      "rds:DescribeDBInstances",
      "rds:CreateDBInstance",
      "rds:DeleteDBInstance",
      "rds:ModifyDBInstance",
      "rds:AddTagsToResource",
      "rds:ListTagsForResource",
      "rds:RemoveTagsFromResource",
      "rds:CreateDBParameterGroup",
      "rds:ModifyDBParameterGroup",
      "rds:DeleteDBParameterGroup",
      "rds:DescribeDBParameters",
      "rds:DescribeDBSnapshots",
      "rds:DeleteDBSnapshot"
    ]

    resources = [
      "arn:${var.aws_partition}:rds:${var.aws_default_region}:${var.account_id}:db:cg-aws-broker-*",
      "arn:${var.aws_partition}:rds:${var.aws_default_region}:${var.account_id}:pg:cg-aws-broker-*",
      "arn:${var.aws_partition}:rds:${var.aws_default_region}:${var.account_id}:snapshot:cg-aws-broker-*",
      "arn:${var.aws_partition}:rds:${var.aws_default_region}:${var.account_id}:subgrp:${var.rds_subgroup}"      
    ]
  }

  statement {
    actions = [
      "rds:DescribeDBParameterGroups"
    ]

    resources = [
      "arn:${var.aws_partition}:rds:${var.aws_default_region}:${var.account_id}:pg:*"
    ]
  } 

  statement {
    actions = [
      "rds:DescribeDBEngineVersions",
      "rds:DescribeEngineDefaultParameters"
    ]

    resources = [
      "*"
    ]
  } 

  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject"
    ]

    resources = [
      "arn:${var.aws_partition}:s3:::${var.remote_state_bucket}",
      "arn:${var.aws_partition}:s3:::${var.remote_state_bucket}/*"
    ]
  }  

  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      "arn:${var.aws_partition}:s3:::${var.remote_state_bucket}/cg-aws-broker-*",
      "arn:${var.aws_partition}:s3:::${var.remote_state_bucket}/cg-aws-broker-*/*"
    ]
  }    

  statement {
    actions = [
	    "s3:GetBucketLocation",
      "s3:ListAllMyBuckets",
      "s3:ListBucket",
      "s3:PutObject",
      "s3:GetBucketAcl"
    ]

    resources = [
      "arn:aws-us-gov:s3:::*"
    ]
  }   

  statement {
    actions = [
      "es:ESHttpGet",
      "es:CreateElasticsearchDomain",
      "es:ListTags",
      "es:DescribeElasticsearchDomainConfig",
      "es:ESHttpDelete",
      "es:GetUpgradeHistory",
      "es:AddTags",
      "es:RemoveTags",
      "es:ESHttpHead",
      "es:DeleteElasticsearchDomain",
      "es:DescribeElasticsearchDomain",
      "es:UpgradeElasticsearchDomain",
      "es:UpdateElasticsearchDomainConfig",
      "es:ESHttpPost",
      "es:GetCompatibleElasticsearchVersions",
      "es:ESHttpPatch",
      "es:GetUpgradeStatus",
      "es:DescribeElasticsearchDomains",
      "es:ESHttpPut"
    ]

    resources = [
      "arn:${var.aws_partition}:es:${var.aws_default_region}:${var.account_id}:domain/cg-*"
    ]
  }        

  statement {
    actions = [
      "es:ListDomainNames",
      "es:ListElasticsearchInstanceTypeDetails",
      "es:CreateElasticsearchServiceRole",
      "es:DeleteElasticsearchServiceRole",
      "es:ListElasticsearchInstanceTypes",
      "es:DescribeElasticsearchInstanceTypeLimits",
      "es:ListElasticsearchVersions"
    ]

    resources = [
      "*"
    ]
  }    

  statement {
    actions = [
      "iam:GetUser",
      "iam:CreateUser",
      "iam:DeleteUser",
      "iam:ListAccessKeys",
      "iam:CreateAccessKey",
      "iam:DeleteAccessKey",
      "iam:CreatePolicy",
      "iam:DeletePolicy",
      "iam:ListAttachedUserPolicies",
      "iam:ListAttachedRolePolicies",
      "iam:AttachUserPolicy",
      "iam:DetachUserPolicy",
      "iam:ListRoles",
      "iam:GetRole",
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:AttachRolePolicy",
      "iam:PassRole",
      "iam:DetachRolePolicy",
      "iam:ListRolePolicies",
      "iam:GetRolePolicy",
      "iam:ListPolicies",
      "iam:ListPolicyVersions",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:CreatePolicyVersion",
      "iam:DeletePolicyVersion",
      "iam:TagUser",
      "iam:UntagUser",
      "iam:TagPolicy",
      "iam:UntagPolicy",
      "iam:TagRole",
      "iam:UntagRole"
    ]

    resources = [
      "arn:${var.aws_partition}:iam::${var.account_id}:user${var.iam_path}*",
      "arn:${var.aws_partition}:iam::${var.account_id}:role${var.iam_path}*",
      "arn:${var.aws_partition}:iam::${var.account_id}:policy${var.iam_path}",
      "arn:${var.aws_partition}:iam::${var.account_id}:policy${var.iam_path}*"
    ]
  }        

  statement {
    actions = [
      "elasticache:DescribeReplicationGroups",
      "elasticache:RemoveTagsFromResource",
      "elasticache:DescribeCacheParameters",
      "elasticache:CreateReplicationGroup",
      "elasticache:AddTagsToResource",
      "elasticache:DeleteReplicationGroup",
      "elasticache:DescribeCacheSubnetGroups",
      "elasticache:IncreaseReplicaCount",
      "elasticache:DescribeCacheParameterGroups",
      "elasticache:ModifyReplicationGroup",
      "elasticache:DecreaseReplicaCount",
      "elasticache:DescribeCacheSecurityGroups",
      "elasticache:ListTagsForResource",
      "elasticache:ModifyReplicationGroupShardConfiguration",
      "elasticache:DescribeSnapshots",
      "elasticache:CreateSnapshot",
      "elasticache:CopySnapshot",
      "elasticache:DeleteSnapshot"
    ]

    resources = [
      "*"
    ]
  }   

  statement {
    actions = [
      "logs:DescribeLogGroups"
    ]

    resources = [
      "*"
    ]
  }    

  statement {
    actions = [
      "logs:TagResource"
    ]

    resources = [
      "arn:${var.aws_partition}:logs:${var.aws_default_region}:${var.account_id}:log-group:/aws/rds/instance/cg-aws-broker*/*",
      "arn:${var.aws_partition}:logs:${var.aws_default_region}:${var.account_id}:log-group:/aws/OpenSearchService/domains/cg-broker*/*"
    ]
  }       
}

resource "aws_iam_policy" "iam_policy" {
  name   = var.policy_name
  policy = data.aws_iam_policy_document.aws_broker_policy.json
}
