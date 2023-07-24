packer {
  required_version = ">= 1.7.0"
  required_plugins {
    amazon = {
      version = ">= 1.0.3"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

data "amazon-ami" "ubuntu-focal-west" {
  region = "us-west-2"
  filters = {
    name = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
  }
  most_recent = true
  owners      = ["099720109477"]
}

source "amazon-ebs" "myapp" {
  region         = "us-west-2"
  source_ami     = data.amazon-ami.ubuntu-focal-west.id
  instance_type  = "t2.nano"
  ssh_username   = "ubuntu"
  ssh_agent_auth = false
  ami_name       = "${var.image_name}_{{timestamp}}"
  associate_public_ip_address = true
  subnet_id = var.subnet_id
  tags = merge(var.default_base_tags, {
    SourceAMIName        = "{{ .SourceAMIName }}"
    builddate            = formatdate("MMM DD, YYYY", timestamp())
    buildtime            = formatdate("HH:mmaa", timestamp())
  })
}

build {
  hcp_packer_registry {
    bucket_name = var.image_name
    description = "Simple static website"

    bucket_labels = var.default_base_tags

    build_labels = {
      "builddate"                = formatdate("MMM DD, YYYY", timestamp())
      "buildtime"                = formatdate("HH:mmaa", timestamp())
      "operating-system"         = "Ubuntu"
      "operating-system-release" = "22.04"
    }
  }

  sources = ["source.amazon-ebs.myapp"]

  // Copy binary to tmp
  provisioner "file" {
    source      = "../bin/server"
    destination = "/tmp/"
  }

  provisioner "file" {
    source      = "./scripts/myapp.service"
    destination = "/tmp/"
  }

  provisioner "shell" {
    script = "./scripts/setup.sh"
  }

  post-processor "manifest" {
    output     = "packer_manifest.json"
    strip_path = true
    custom_data = {
      iteration_id = packer.iterationID
    }
  }
}
