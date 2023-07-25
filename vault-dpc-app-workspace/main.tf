locals {
  myapp_ca_chain = <<EOH
${vault_pki_secret_backend_cert.myapp.certificate}
${vault_pki_secret_backend_cert.myapp.ca_chain}
  EOH

  env_file = <<EOH
DB_USER=${data.vault_kv_secret_v2.db_creds.data.admin_username}
DB_PASSWORD=${data.vault_kv_secret_v2.db_creds.data.admin_password}
DB_HOST=${var.db_address}
  EOH

  cloudinit_config_myapp = {
    write_files = [
      {
        content     = local.myapp_ca_chain
        owner       = "ubuntu:ubuntu"
        path        = "/opt/webapp/cert.pem"
        permissions = "0644"
      },
      {
        content     = vault_pki_secret_backend_cert.myapp.private_key
        owner       = "ubuntu:ubuntu"
        path        = "/opt/webapp/key.pem"
        permissions = "0644"
      },
      {
        content     = local.env_file
        owner       = "ubuntu:ubuntu"
        path        = "/opt/webapp/env_file.conf"
        permissions = "0644"
      },
    ]
    runcmd = [
      ["systemctl", "start", "myapp"],
    ]
  }
}

data "cloudinit_config" "myapp" {
  gzip          = false
  base64_encode = true
  part {
    content_type = "text/cloud-config"
    content      = yamlencode(local.cloudinit_config_myapp)
  }
}

# resource "aws_key_pair" "myapp_server_key" {
#   key_name = "myapp_server_key"
#   public_key = var.public_key
# }

resource "aws_instance" "myapp" {
  lifecycle {
    ignore_changes = [user_data_base64]
  }

  ami           = data.hcp_packer_image.myapp.cloud_image_id
  instance_type = "t3.micro"

  associate_public_ip_address = true
  #key_name                    = aws_key_pair.myapp_server_key.key_name
  monitoring                  = true
  subnet_id                   = data.aws_subnets.subnet_id.ids[0]
  vpc_security_group_ids      = [module.myapp-sec-group.security_group_id]
  user_data_base64            = data.cloudinit_config.myapp.rendered
  user_data_replace_on_change = false
  tags = {
    Name = "myapp"
  }
}

#Create worker EC2 security group
module "myapp-sec-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name   = "myapp-sec-group"
  vpc_id = data.aws_vpc.vpc_id.id

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["https-443-tcp", "http-80-tcp", "postgresql-tcp"]

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp"]

  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow traffic on web port"
    },
    {
      from_port   = 8443
      to_port     = 8443
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow traffic on web port"
    }
  ]
}

resource "vault_pki_secret_backend_cert" "myapp" {
  backend     = "pki_int"
  name        = "server"
  ttl         = "72h"
  common_name = "myapp.swcloudlab.net"
}