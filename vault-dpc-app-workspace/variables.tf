variable "region" {
  type        = string
  description = "The AWS region to deploy infrastructure into"
}

variable "tfc_hostname" {
  type        = string
  description = "The TFE/TFC hostname"
}

variable "tfc_organization_name" {
  type        = string
  description = "The TFC Organization Name"
}

variable "tfc_project_name" {
  type        = string
  description = "The TFC Project to deploy into"
}

variable "tfc_token" {
  type        = string
  description = "The token to use to configure the TFE provider"
}

variable "vault_addr" {
  type        = string
  description = "The private address of the Vault server"
}

variable "hcp_client_id" {
  type        = string
  description = "The client ID to use in the HCP provider"
}

variable "hcp_client_secret" {
  type        = string
  description = "The client secret to use in the HCP provider"
}

variable "db_address" {
  type        = string
  description = "The address of the database instance to connect to myapp server to"
}