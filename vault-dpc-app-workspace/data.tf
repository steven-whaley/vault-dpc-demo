data "hcp_packer_image" "myapp" {
  bucket_name    = "vault-dpc-demo-myapp"
  channel        = "latest"
  cloud_provider = "aws"
  region         = "us-west-2"
}

data "vault_kv_secret_v2" "db_creds" {
  mount = "kv"
  name = "database_credentials"
}

data "aws_vpc" "vpc_id" {
    tags = {
        Name = "vault-dpc-demo-vpc"
    }
}

data "aws_subnets" "subnet_id" {
    filter {
        name   = "vpc-id"
        values = [data.aws_vpc.vpc_id.id]
     }
    
    tags = {
        Public = "Yes"
    }
}