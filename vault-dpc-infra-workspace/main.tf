resource "random_string" "db_password" {
  length  = 16
  special = false
}

resource "random_string" "db_admin_name" {
  length  = 8
  special = false
  numeric = false
}

# Create VPC for AWS resources
module "vault-dpc-demo-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"

  name = "vault-dpc-demo-vpc"

  cidr = "10.10.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = ["10.10.11.0/24", "10.10.12.0/24"]
  public_subnets  = ["10.10.21.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    Public = "Yes"
  }
}

### Create peering connection to Vault HVN 
resource "hcp_aws_network_peering" "vault" {
  hvn_id          = var.hvn_id
  peering_id      = "vault-dpc-demo-cluster"
  peer_vpc_id     = module.vault-dpc-demo-vpc.vpc_id
  peer_account_id = module.vault-dpc-demo-vpc.vpc_owner_id
  peer_vpc_region = var.region
}

resource "aws_vpc_peering_connection_accepter" "peer" {
  vpc_peering_connection_id = hcp_aws_network_peering.vault.provider_peering_id
  auto_accept               = true
}

resource "time_sleep" "wait_60s" {
  depends_on = [
    aws_vpc_peering_connection_accepter.peer
  ]
  create_duration = "60s"
}

resource "aws_vpc_peering_connection_options" "dns" {
  depends_on = [
    time_sleep.wait_60s
  ]
  vpc_peering_connection_id = hcp_aws_network_peering.vault.provider_peering_id
  accepter {
    allow_remote_vpc_dns_resolution = true
  }
}

resource "hcp_hvn_route" "hcp_vault" {
  hvn_link         = var.hvn_self_link
  hvn_route_id     = "vault-dpc-instruqt"
  destination_cidr = module.vault-dpc-demo-vpc.vpc_cidr_block
  target_link      = hcp_aws_network_peering.vault.self_link
}

resource "aws_route" "vault" {
  for_each = {
    for idx, rt_id in module.vault-dpc-demo-vpc.private_route_table_ids : idx => rt_id
  }
  route_table_id            = each.value
  destination_cidr_block    = var.hvn_cidr
  vpc_peering_connection_id = hcp_aws_network_peering.vault.provider_peering_id
}

# Create AWS RDS Database
resource "aws_db_subnet_group" "postgres" {
  name       = "vault-dpc-demo"
  subnet_ids = module.vault-dpc-demo-vpc.private_subnets
}

resource "aws_db_instance" "postgres" {
  allocated_storage           = 10
  db_name                     = "myappdb"
  engine                      = "postgres"
  engine_version              = "12.15"
  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = false
  instance_class              = "db.t3.micro"
  username                    = random_string.db_admin_name.result
  password                    = random_string.db_password.result
  db_subnet_group_name        = aws_db_subnet_group.postgres.name
  skip_final_snapshot         = true
  vpc_security_group_ids      = [module.rds-sec-group.security_group_id]

  tags = {
    Name = "myappdb"
  }
}

#RDS Security Group
module "rds-sec-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name        = "rds-sec-group"
  description = "Allow Access from HCP Vault to Database Endpoint"
  vpc_id      = module.vault-dpc-demo-vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      rule        = "postgresql-tcp"
      cidr_blocks = "${var.hvn_cidr},${module.vault-dpc-demo-vpc.vpc_cidr_block}"
    }
  ]
}

# Add Database username and password into Vault
resource "vault_kv_secret_v2" "database_credentials" {
  mount               = "kv"
  name                = "database_credentials"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      admin_username = random_string.db_admin_name.result,
      admin_password = random_string.db_password.result
    }
  )
}

# Add DB address as variable to vault-dpc-app-workspace
resource "tfe_variable" "db_address" {
  key          = "db_address"
  value        = aws_db_instance.postgres.address
  category     = "terraform"
  workspace_id = data.tfe_workspace.vault-dpc-app-workspace.id
}