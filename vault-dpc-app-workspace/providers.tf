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
  }
  cloud {
    organization = "swhashi"
    workspaces {
      name = "vault-dpc-app-workspace"
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