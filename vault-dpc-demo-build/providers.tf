terraform {
  required_version = ">= 1.0"
  required_providers {
    tfe = {
      version = "0.47.0"
    }
    vault = {
        version = "3.18.0"
    }
    aws = {
      version = "5.4.0"
      source  = "hashicorp/aws"
    }
  }
  cloud {
    organization = "swhashi"
    workspaces {
      name = "vault-dpc-demo-build"
    }
  }
}

provider "tfe" {
    hostname = var.tfc_hostname
    token = var.tfc_token
}

provider "vault" {
    namespace = "admin"  
    address = var.vault_addr
}

provider "aws" {
    region = var.region
}