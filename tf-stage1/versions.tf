terraform {
  required_providers {
    external = {
      source = "hashicorp/external"
    }
    hcloud = {
      source = "hetznercloud/hcloud"
    }
    hetznerdns = {
      source = "timohirt/hetznerdns"
    }
    minio = {
      source = "aminueza/minio"
    }
  }
  required_version = ">= 0.13"
}
