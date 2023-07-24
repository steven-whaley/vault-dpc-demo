
variable "image_name" {
  type    = string
  default = "vault-dpc-demo-myapp"
}

variable "default_base_tags" {
  description = "Required tags for the environment"
  type        = map(string)
  default = {
    owner   = "App Team"
    contact = "myapp@swcloudlab.net"
  }
}

variable "subnet_id" {
  description = "The VPC ID of the VPC to use to build the AMI"
  type = string
}