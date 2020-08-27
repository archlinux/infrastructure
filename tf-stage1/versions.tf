terraform {
  required_providers {
    external = {
      source = "hashicorp/external"
    }
    hcloud = {
      source = "hetznercloud/hcloud"
    }
  }
  required_version = ">= 0.13"
}
