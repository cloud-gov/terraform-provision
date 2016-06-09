
module "s3_broker_user" {
    source = ".."

    username = "${var.username}"

    /* TODO: Make the bucket names configurable */
    /* TODO: Make sure the bucket arn:path is configurable */
    iam_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "manageBucketsAndObjectsInBuckets",
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": [
                "arn:aws-us-gov:s3:::cg-*",
                "arn:aws-us-gov:s3:::cg-*/*"
            ]
        },
        {
            "Sid": "manageUsersForBinding",
            "Effect": "Allow",
            "Action": [
                "iam:AddUserToGroup",
                "iam:ChangePassword",
                "iam:CreateAccessKey",
                "iam:CreateGroup",
                "iam:CreateUser",
                "iam:DeleteAccessKey",
                "iam:DeleteGroup",
                "iam:DeleteGroupPolicy",
                "iam:DeleteUser",
                "iam:DeleteUserPolicy",
                "iam:GetGroup",
                "iam:GetGroupPolicy",
                "iam:GetUser",
                "iam:ListAccessKeys",
                "iam:ListGroups",
                "iam:ListGroupsForUser",
                "iam:ListUsers",
                "iam:PutGroupPolicy",
                "iam:RemoveUserFromGroup",
                "iam:UpdateGroup",
                "iam:UpdateUser"
            ],
            "Resource": [
                "arn:aws-us-gov:iam::${var.account_id}:user/cloud-foundry/s3/*",
                "arn:aws-us-gov:iam::${var.account_id}:group/cloud-foundry/s3/",
                "arn:aws-us-gov:iam::${var.account_id}:group/cloud-foundry/s3/*"
            ]
        }
    ]
}
EOF
}
