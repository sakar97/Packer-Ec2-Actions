#packer file
packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.6"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "ami_name" {
  type = string
  default = "packer-windows-{{timestamp}}"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

# https://www.packer.io/docs/builders/amazon/ebs
source "amazon-ebs" "windows" {
  ami_name = "${var.ami_name}"
  instance_type = "t2.micro"
  region = "${var.region}"
  source_ami_filter {
    filters = {
      name = "Windows_Server-2022-English-Full-Base-*"
      root-device-type = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners = ["amazon"]
  }
  communicator = "winrm"
  winrm_username = "Administrator"
  winrm_use_ssl = true
  winrm_insecure = true

  # This user data file sets up winrm and configures it so that the connection
  # from Packer is allowed. Without this file being set, Packer will not
  # connect to the instance.
}

# https://www.packer.io/docs/provisioners
build {
  sources = ["source.amazon-ebs.windows"]

  provisioner "powershell" {
    script = "update_windows.ps1"
  }
}
