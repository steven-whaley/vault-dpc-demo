# Create auth backend for TFC to use to authenticate to Vault
resource "vault_jwt_auth_backend" "tfc_jwt" {
  path               = "tfc_jwt"
  type               = "jwt"
  oidc_discovery_url = "https://${var.tfc_hostname}"
  bound_issuer       = "https://${var.tfc_hostname}"
}

# Create Vault KV Secrets Engine
resource "vault_mount" "kvv2" {
  path        = "kv"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount"
}

resource "vault_kv_secret_backend_v2" "example" {
  mount        = vault_mount.kvv2.path
  max_versions = 5
}


# Create and configure PKI Secrets Engine
# Create the Root CA
resource "vault_mount" "pki_root" {
  path = "pki_root"
  type = "pki"
  description = "SWCloudlab Root CA"
}

resource "vault_pki_secret_backend_root_cert" "root_ca" {
  backend               = vault_mount.pki_root.path
  type                  = "internal"
  common_name           = "SW Cloudlab Root CA"
  ttl                   = 31557600
  format                = "pem"
  private_key_format    = "der"
  key_type              = "rsa"
  key_bits              = 4096
  exclude_cn_from_sans  = true
  ou                    = "Vault Dynamic Provider OU"
  organization          = "swcloublab"
}

resource "vault_pki_secret_backend_config_urls" "root_urls" {
  backend = vault_mount.pki_root.path
  issuing_certificates = [
    "http://127.0.0.1:8200/v1/pki/ca",
  ]
}

# Create Intermediate CA
resource "vault_mount" "pki_int" {
  path = "pki_int"
  type = "pki"
  description = "SWCloudLab Intermediate CA"
}

resource "vault_pki_secret_backend_intermediate_cert_request" "pki_int" {
  depends_on = [ vault_mount.pki_root ]
  backend     = vault_mount.pki_int.path
  type        = "internal"
  common_name = "SWCloudlab Intermediate CA"
}

resource "vault_pki_secret_backend_root_sign_intermediate" "int" {
  depends_on           = [ vault_pki_secret_backend_intermediate_cert_request.pki_int ]
  backend              = vault_mount.pki_root.path
  csr                  = vault_pki_secret_backend_intermediate_cert_request.pki_int.csr
  ttl = 7889400
  common_name          = "SWCloudlab Intermediate CA"
  ou                   = "Vault Dynamic Provider Lab"
  organization         = "swcloudlab"
  issuer_ref = "default"
}

resource "vault_pki_secret_backend_intermediate_set_signed" "pki_int" {
  backend     = vault_mount.pki_int.path
  certificate = vault_pki_secret_backend_root_sign_intermediate.int.certificate
}

resource "vault_pki_secret_backend_role" "role" {
  backend          = vault_mount.pki_int.path
  name             = "server"
  ttl              = 2592000
  allow_ip_sans    = true
  key_type         = "rsa"
  key_bits         = 4096
  allowed_domains  = ["swcloudlab.net", "local"]
  allow_subdomains = true
}


# Create and Configure AWS Secrets Engine
#Create policy for AWS dynamic creds read
resource "vault_policy" "aws" {
  name   = "aws"
  policy = <<EOT
    path "aws/creds/vault-demo-iam-user"
    {
        capabilities = ["read"]
    }
    EOT
}

# Create IAM user and keys that Vault can use to connect to AWS to generate short lived credentials
resource "aws_iam_user" "vault_aws_user" {
  name                 = "vault-aws-secrets-user"
  force_destroy        = true
}

resource "aws_iam_policy" "vault_aws_policy" {
  name = "vault-aws-secrets-user-policy"
  policy = data.aws_iam_policy_document.vault_aws_secrets_user_policy.json
}

resource "aws_iam_user_policy_attachment" "vault_aws_user" {
  user       = aws_iam_user.vault_aws_user.name
  policy_arn     = aws_iam_policy.vault_aws_policy.arn
}

resource "aws_iam_access_key" "vault_aws_key" {
  user = aws_iam_user.vault_aws_user.name
}

resource "vault_aws_secret_backend" "vault_aws" {
  access_key        = aws_iam_access_key.vault_aws_key.id
  secret_key        = aws_iam_access_key.vault_aws_key.secret
  description       = "Demo of the AWS secrets engine"
  region            = var.region
}