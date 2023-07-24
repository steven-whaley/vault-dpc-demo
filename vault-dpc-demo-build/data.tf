data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "vault_aws_secrets_user_policy" {
  statement {
    sid       = "VaultAWSSecretsUserPolicy"
    actions   = [        
        "iam:AttachUserPolicy",
        "iam:CreateAccessKey",
        "iam:CreateUser",
        "iam:DeleteAccessKey",
        "iam:DeleteUser",
        "iam:DeleteUserPolicy",
        "iam:DetachUserPolicy",
        "iam:GetUser",
        "iam:ListAccessKeys",
        "iam:ListAttachedUserPolicies",
        "iam:ListGroupsForUser",
        "iam:ListUserPolicies",
        "iam:PutUserPolicy",
        "iam:AddUserToGroup",
        "iam:RemoveUserFromGroup"
    ]
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/vault-*"]
  }
}

data "aws_iam_policy" "ec2_read" {
  name = "AmazonEC2ReadOnlyAccess"
}

data "aws_iam_policy" "ec2_all" {
  name = "AmazonEC2FullAccess"
}

data "aws_iam_policy" "vpc_read" {
  name = "AmazonVPCReadOnlyAccess"
}

data "aws_iam_policy" "vpc_all" {
  name = "AmazonVPCFullAccess"
}

data "aws_iam_policy" "rds_read" {
  name = "AmazonRDSReadOnlyAccess"
}

data "aws_iam_policy" "rds_all" {
  name = "AmazonRDSFullAccess"
}