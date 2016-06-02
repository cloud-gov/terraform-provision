
module "bosh_user" {
    source = ".."

    username = "${var.username}"
    iam_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Deny",
        "Action": [
            "iam:*"
        ],
        "Resource": [
            "*"
        ]
    },
    {
        "Sid": "S3Access",
        "Effect": "Allow",
        "Action": [
            "s3:PutObject",
            "s3:GetObject",
            "s3:DeleteObject"
        ],
        "Resource": [
            "*"
        ]
    },
    {
        "Sid": "BoshDeployments",
        "Effect": "Allow",
        "Action": [
            "ec2:DescribeAccountAttributes",
            "ec2:DescribeAvailabilityZones",
            "ec2:DescribeKeypairs",
            "ec2:DescribeVpcs",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeSubnets",
            "ec2:DescribeImages",
            "ec2:RegisterImage",
            "ec2:DeregisterImage",
            "ec2:RunInstances",
            "ec2:DescribeInstances",
            "ec2:TerminateInstances",
            "ec2:RebootInstances",
            "elasticloadbalancing:DescribeLoadBalancers",
            "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
            "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
            "ec2:DescribeAddresses",
            "ec2:DisassociateAddress",
            "ec2:AssociateAddress",
            "ec2:CreateTags",
            "ec2:DescribeVolumes",
            "ec2:CreateVolume",
            "ec2:AttachVolume",
            "ec2:DeleteVolume",
            "ec2:DetachVolume",
            "ec2:CreateSnapshot",
            "ec2:DeleteSnapshot",
            "ec2:DescribeSnapshots",
            "ec2:DescribeRegions"
        ],
        "Resource": [
            "*"
        ]
    }
]
}
EOF
}