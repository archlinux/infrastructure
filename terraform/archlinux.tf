terraform {
  backend "pg" {}
}

variable "hetzner_cloud_api_key" {}

# Find the id using `hcloud image list`
variable "archlinux_image_id" {
  default = "2923545"
}

provider "hcloud" {
  token = "${var.hetzner_cloud_api_key}"
}

resource "hcloud_floating_ip" "bbs" {
  type = "ipv4"
  server_id = "${hcloud_server.bbs.id}"
}

resource "hcloud_rdns" "bbs" {
  floating_ip_id = "${hcloud_floating_ip.bbs.id}"
  ip_address = "${hcloud_floating_ip.bbs.ip_address}"
  dns_ptr = "bbs.archlinux.org"
}

resource "hcloud_server" "bbs" {
  name = "bbs.archlinux.org"
  image = "${var.archlinux_image_id}"
  server_type = "cx11"
}
