terraform {
  backend "pg" {}
}

data "external" "hetzner_cloud_api_key" {
  program = ["${path.module}/misc/get_key.py", "misc/vault_hetzner.yml", "hetzner_cloud_api_key", "json"]
}

data "hcloud_image" "archlinux" {
  with_selector = "custom_image=archlinux"
  most_recent = true
  with_status = ["available"]
}

provider "hcloud" {
  token = "${data.external.hetzner_cloud_api_key.result.hetzner_cloud_api_key}"
}

resource "hcloud_rdns" "quassel" {
  server_id  = "${hcloud_server.quassel.id}"
  ip_address = "${hcloud_server.quassel.ipv4_address}"
  dns_ptr    = "quassel.archlinux.org"
}

resource "hcloud_server" "quassel" {
  name        = "quassel.archlinux.org"
  image       = "${data.hcloud_image.archlinux.id}"
  server_type = "cx11"
  lifecycle {
    ignore_changes = [image]
  }
}

resource "hcloud_rdns" "phrik" {
  server_id  = "${hcloud_server.phrik.id}"
  ip_address = "${hcloud_server.phrik.ipv4_address}"
  dns_ptr    = "phrik.archlinux.org"
}

resource "hcloud_server" "phrik" {
  name        = "phrik.archlinux.org"
  image       = "${data.hcloud_image.archlinux.id}"
  server_type = "cx11"
  lifecycle {
    ignore_changes = [image]
  }
}

resource "hcloud_rdns" "bbs" {
  server_id  = "${hcloud_server.bbs.id}"
  ip_address = "${hcloud_server.bbs.ipv4_address}"
  dns_ptr    = "bbs.archlinux.org"
}

resource "hcloud_server" "bbs" {
  name        = "bbs.archlinux.org"
  image       = "${data.hcloud_image.archlinux.id}"
  server_type = "cx21"
  lifecycle {
    ignore_changes = [image]
  }
}

resource "hcloud_rdns" "gitlab" {
  server_id  = "${hcloud_server.gitlab.id}"
  ip_address = "${hcloud_server.gitlab.ipv4_address}"
  dns_ptr    = "gitlab.archlinux.org"
}

resource "hcloud_server" "gitlab" {
  name        = "gitlab.archlinux.org"
  image       = "${data.hcloud_image.archlinux.id}"
  server_type = "cx21"
  lifecycle {
    ignore_changes = [image]
  }
}

resource "hcloud_rdns" "ldap" {
  server_id  = "${hcloud_server.ldap.id}"
  ip_address = "${hcloud_server.ldap.ipv4_address}"
  dns_ptr    = "ldap.archlinux.org"
}

resource "hcloud_server" "ldap" {
  name        = "ldap.archlinux.org"
  image       = "${data.hcloud_image.archlinux.id}"
  server_type = "cx11"
  lifecycle {
    ignore_changes = [image]
  }
}

resource "hcloud_rdns" "matrix" {
  server_id  = "${hcloud_server.matrix.id}"
  ip_address = "${hcloud_server.matrix.ipv4_address}"
  dns_ptr    = "matrix.archlinux.org"
}

resource "hcloud_server" "matrix" {
  name        = "matrix.archlinux.org"
  image       = "${data.hcloud_image.archlinux.id}"
  server_type = "cx21"
  lifecycle {
    ignore_changes = [image]
  }
}
