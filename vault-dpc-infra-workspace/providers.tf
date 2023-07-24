terraform {
  required_version = ">= 1.0"
  required_providers {
    vault = {
        version = "3.18.0"
    }
    aws = {
      version = "5.4.0"
      source  = "hashicorp/aws"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "0.66.0"
    }
  }
  cloud {
    organization = "swhashi"
    workspaces {
      name = "vault-dpc-infra-workspace"
    }
  }
}

provider "vault" {
    namespace = "admin"  
    address = var.vault_addr
}

provider "aws" {
    region = var.region
}

provider "hcp" {
    client_id = var.hcp_client_id
    client_secret = var.hcp_client_secret
}