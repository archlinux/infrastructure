terraform {
  backend "pg" {}
}

data "external" "hetzner_cloud_api_key" {
  program = ["bash", "${path.module}/misc/get_hetzner_cloud_api_key_terraform.sh"]
}

# Find the id using `hcloud image list`
variable "archlinux_image_id" {
  default = "2923545"
}

provider "hcloud" {
  token = "${data.external.hetzner_cloud_api_key.result.hetzner_cloud_api_key}"
}

resource "hcloud_rdns" "bbs" {
  server_id  = "${hcloud_server.bbs.id}"
  ip_address = "${hcloud_server.bbs.ipv4_address}"
  dns_ptr    = "bbs.archlinux.org"
}

resource "hcloud_server" "bbs" {
  name        = "bbs.archlinux.org"
  image       = "${var.archlinux_image_id}"
  server_type = "cx11"
}

resource "hcloud_rdns" "quassel" {
  server_id  = "${hcloud_server.quassel.id}"
  ip_address = "${hcloud_server.quassel.ipv4_address}"
  dns_ptr    = "quassel.archlinux.org"
}

resource "hcloud_server" "quassel" {
  name        = "quassel.archlinux.org"
  image       = "${var.archlinux_image_id}"
  server_type = "cx11"
}
