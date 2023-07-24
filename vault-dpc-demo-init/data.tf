data "tfe_project" "vault-dpc-demo" {
  organization = var.tfc_organization_name
  name         = var.tfc_project_name
}

