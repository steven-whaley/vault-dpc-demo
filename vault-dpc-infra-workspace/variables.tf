variable "region" {
  type = string
  description = "The AWS region to deploy infrastructure into"
}

variable "tfc_hostname" {
    type = string
    description = "The TFE/TFC hostname"
}

variable "tfc_token" {
    type = string
    description = "The token to use to configure the TFE provider"
}

variable "tfc_organization_name" {
    type = string
    description = "The organization name used to configure the TFC provider"
}

variable "vault_addr" {
    type = string
    description = "The public address of the Vault server"
}

variable "hvn_id" {
    type = string
    description = "The ID of the HVN we want to peer with"
}

variable "hvn_cidr" {
    type = string
    description = "The CIDR range of the HVN we want to peer with"
}

variable "hvn_self_link" {
    type = string
    description = "The self link of the HVN to peer with"
}

variable "hcp_client_id" {
    type = string
    description = "The client ID to use in the HCP provider"
}

variable "hcp_client_secret" {
    type = string
    description = "The client secret to use in the HCP provider"
}