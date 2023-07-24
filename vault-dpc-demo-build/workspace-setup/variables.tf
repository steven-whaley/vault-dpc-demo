variable "tfc_organization_name" {
  type        = string
  description = "The name of your Terraform Cloud organization"
}

variable "tfc_project_name" {
  type        = string
  description = "The project under which a workspace will be created"
}

variable "tfc_workspace_name" {
  type        = string
  description = "The name of the workspace that you'd like to create and connect to Vault"
}

variable "vault_workspace_variables" {
    type = map
    description = "Variables used in the Vault Provider consumer workspace"
    # vault_workspace_variables = {
    #     "TFC_VAULT_ADDR" = "https://vault.local:8200"
    #     "TFC_VAULT_AUTH_PATH" = "jwt"
    #     "TFC_VAULT_NAMESPACE" = "admin"
    #     "TFC_VAULT_PROVIDER_AUTH" = "true"
    #     "TFC_VAULT_BACKED_AWS_AUTH" = "true"
    #     "TFC_VAULT_BACKED_AWS_AUTH_TYPE" = "iam_user"
    #     "TFC_VAULT_BACKED_AWS_PLAN_VAULT_ROLE" = "tf_${var.tfc_workspace_name}_plan_role"
    #     "TFC_VAULT_BACKED_AWS_APPLY_VAULT_ROLE" = "tf_${var.tfc_workspace_name}_apply_role"
    #     "TFC_VAULT_BACKED_AWS_MOUNT_PATH" = "aws"    
    # }
}

variable "vault_plan_policy" {
    type = string
    description = "HEREDOC string with Vault plan policy to create for this workspace"
#     vault_plan_policy = <<EOT
# # Allow tokens to query themselves
# path "auth/token/lookup-self" {
#   capabilities = ["read"]
# }

# # Allow tokens to renew themselves
# path "auth/token/renew-self" {
#     capabilities = ["update"]
# }

# # Allow tokens to revoke themselves
# path "auth/token/revoke-self" {
#     capabilities = ["update"]
# }

# path "kv/*" {
#   capabilities = ["read", "list"]
# }

# path "${data.tfe_outputs.vault_dynamic_provider_build.values.db_secrets_path}/creds/${data.tfe_outputs.vault_dynamic_provider_build.values.db_secrets_role}" {
#   capabilities = ["read", "list"]
# }

# path "${data.tfe_outputs.vault_dynamic_provider_build.values.pki_int_path}/issue/${data.tfe_outputs.vault_dynamic_provider_build.values.pki_int_role}" {
#  capabilities = ["read", "list"]
# }
#EOT
}

variable "vault_apply_policy" {
    type = string
    description = "HEREDOC string with Vault apply policy to create for this workspace"
}

variable "vault_aws_plan_policy_arns" {
  type = list
  description = "List of ARNs of policies to attach to the plan phase role"
}

variable "vault_aws_apply_policy_arns" {
  type = list
  description = "List of ARNs of policies to attach to the plan phase role"
}

variable "aws_secrets_backend" {
  type = string
  description = "The AWS secrets backend on which to create the roles"
}