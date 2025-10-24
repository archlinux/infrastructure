# https://www.packer.io/docs/templates/hcl_templates/blocks/packer
packer {
  required_plugins {
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = ">= 1.1.4"
    }
    hcloud = {
      source  = "github.com/hetznercloud/hcloud"
      version = ">= 1.7.0"
    }
  }
}

# https://www.packer.io/docs/templates/hcl_templates/variables#type-constraints
variable "hetzner_cloud_api_key" {
  type      = string
  sensitive = true
}

variable "install_ec2_public_keys_service" {
  type    = bool
  default = false
}

# https://www.packer.io/docs/templates/hcl_templates/blocks/source
source "hcloud" "rescue" {
  image       = "ubuntu-24.04"
  location    = "fsn1"
  rescue      = "linux64"
  server_type = "cx23"
  snapshot_labels = {
    custom_image = "archlinux"
  }
  snapshot_name = "archlinux-${timestamp()}"
  ssh_username  = "root"
  token         = var.hetzner_cloud_api_key
}

# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = ["source.hcloud.rescue"]

  provisioner "ansible" {
    host_alias          = "packer-base-image"
    inventory_directory = "."
    playbook_file       = "playbooks/tasks/install_arch.yml"
    extra_arguments = [
      "--extra-vars", jsonencode({
        ansible_python_interpreter : "/usr/bin/python3"
        install_ec2_public_keys_service : var.install_ec2_public_keys_service
      })
    ]
    use_proxy = false
  }
}
