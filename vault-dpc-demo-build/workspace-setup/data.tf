data "tfe_project" "vault-dynamic-provider" {
  organization = var.tfc_organization_name
  name         = var.tfc_project_name
}