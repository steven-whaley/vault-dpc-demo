locals {
  app_workspace_name = "vault-dpc-app-workspace"
}

# Vault Policies for the App workspace
data "vault_policy_document" "vault_app_plan_policy" {
  rule {
    path         = "auth/token/lookup-self"
    capabilities = ["read"]
    description  = "Read own token"
  }
  rule {
    path         = "auth/token/renew-self"
    capabilities = ["update"]
    description  = "Renew own token"
  }
  rule {
    path         = "auth/token/revoke-self"
    capabilities = ["update"]
    description  = "Revoke own token"
  }
  rule {
    path         = "kv/*"
    capabilities = ["read", "list"]
    description  = "Read values from KV store"
  }
  rule {
    path         = "${vault_aws_secret_backend.vault_aws.path}/creds/tf_${local.app_workspace_name}_plan_role"
    capabilities = ["read", "list"]
    description  = "Get AWS Credentials"
  }
  rule {
    path         = "${vault_mount.pki_int.path}/issue/${vault_pki_secret_backend_role.role.name}"
    capabilities = ["read", "list"]
    description  = "Get PKI Certificate"
  }
}

data "vault_policy_document" "vault_app_apply_policy" {
  rule {
    path         = "auth/token/lookup-self"
    capabilities = ["read"]
    description  = "Read own token"
  }
  rule {
    path         = "auth/token/renew-self"
    capabilities = ["update"]
    description  = "Renew own token"
  }
  rule {
    path         = "auth/token/revoke-self"
    capabilities = ["update"]
    description  = "Revoke own token"
  }
  rule {
    path         = "kv/*"
    capabilities = ["read", "list", "create", "update", "delete"]
    description  = "Full rights on the KV store"
  }
  rule {
    path         = "${vault_aws_secret_backend.vault_aws.path}/creds/tf_${local.app_workspace_name}_apply_role"
    capabilities = ["read", "list"]
    description  = "Get AWS Credentials"
  }
  rule {
    path         = "${vault_mount.pki_int.path}/issue/${vault_pki_secret_backend_role.role.name}"
    capabilities = ["read", "list", "create", "update"]
    description  = "Get PKI Certificate"
  }
}

module "vault-dpc-app-workspace" {
    source = "./workspace-setup"

    tfc_organization_name = var.tfc_organization_name
    tfc_project_name = var.tfc_project_name
    tfc_workspace_name = local.app_workspace_name

    # Set variables in the workspace to use Vault OIDC auth and Dynamic provider auth for AWS
    vault_workspace_variables = {
         "TFC_VAULT_ADDR" = var.vault_addr
         "TFC_VAULT_AUTH_PATH" = vault_jwt_auth_backend.tfc_jwt.path
         "TFC_VAULT_NAMESPACE" = "admin"
         "TFC_VAULT_PROVIDER_AUTH" = "true"    
         "TFC_VAULT_BACKED_AWS_AUTH" = "true"
         "TFC_VAULT_BACKED_AWS_AUTH_TYPE" = "iam_user"
         "TFC_VAULT_BACKED_AWS_PLAN_VAULT_ROLE" = "tf_${local.app_workspace_name}_plan_role"
         "TFC_VAULT_BACKED_AWS_APPLY_VAULT_ROLE" = "tf_${local.app_workspace_name}_apply_role"
         "TFC_VAULT_BACKED_AWS_MOUNT_PATH" = vault_aws_secret_backend.vault_aws.path   
    }

    # Set the policy to be created for the TFC user accessing Vault
    vault_plan_policy = data.vault_policy_document.vault_app_plan_policy.hcl
    vault_apply_policy = data.vault_policy_document.vault_app_apply_policy.hcl

    # Set the policy to be used for the AWS user created by the aws secrets engine for this workspace
    vault_aws_plan_policy_arns = [data.aws_iam_policy.ec2_read.arn, data.aws_iam_policy.vpc_read.arn, data.aws_iam_policy.rds_read.arn]
    vault_aws_apply_policy_arns = [data.aws_iam_policy.ec2_all.arn]
    aws_secrets_backend = vault_aws_secret_backend.vault_aws.path
}