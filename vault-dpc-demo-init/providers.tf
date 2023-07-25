terraform {
  required_version = ">= 1.0"
  required_providers {
    hcp = {
      source  = "hashicorp/hcp"
      version = "0.66.0"
    }
    tfe = {
      version = "0.47.0"
    }
  }
  cloud {
    organization = "swhashi"
    workspaces {
      name = "vault-dpc-demo-init"
    }
  }
}

provider "hcp" {
  client_id     = var.hcp_client_id
  client_secret = var.hcp_client_secret
}

provider "tfe" {
  hostname     = var.tfc_hostname
  token        = var.tfc_token
  organization = var.tfc_organization_name
}