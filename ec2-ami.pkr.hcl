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
  source_ami = "ami-04132f301c3e4f138"
  communicator = "winrm"
  winrm_username = "Administrator"
  user_data_file = "./winrm.ps1"
  winrm_use_ssl = true
  winrm_insecure = true
}

# https://www.packer.io/docs/provisioners
build {
  sources = ["source.amazon-ebs.windows"]
  provisioner "powershell" {
    inline = [
     "C:\\ProgramData\\Amazon\\EC2-Windows\\Launch\\Scripts\\SendWindowsIsReady.ps1 -Schedule",
      "C:\\ProgramData\\Amazon\\EC2-Windows\\Launch\\Scripts\\InitializeInstance.ps1 -Schedule",
      "C:\\ProgramData\\Amazon\\EC2-Windows\\Launch\\Scripts\\SysprepInstance.ps1 -NoShutdown"
    ]
  }
}
