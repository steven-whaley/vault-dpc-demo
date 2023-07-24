data "aws_availability_zones" "available" {
  state = "available"
}

data "tfe_workspace" "vault-dpc-app-workspace" {
  name = "vault-dpc-app-workspace"
  organization = var.tfc_organization_name
}