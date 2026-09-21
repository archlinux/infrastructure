data "external" "vault_scaleway" {
  program = [
    "${path.module}/../misc/get_key.py", "${path.module}/../misc/vaults/vault_scaleway.yml",
    "scaleway_api_access_key",
    "scaleway_api_secret_key",
    "scaleway_organization_id",
    "scaleway_project_id",
    "--format", "json"
  ]
}

provider "scaleway" {
  access_key      = data.external.vault_scaleway.result.scaleway_api_access_key
  secret_key      = data.external.vault_scaleway.result.scaleway_api_secret_key
  organization_id = data.external.vault_scaleway.result.scaleway_organization_id
  project_id      = data.external.vault_scaleway.result.scaleway_project_id
}

# A small test VM to validate our Scaleway integration.
locals {
  # Note that some pubkeys files contain more than one key, hence the split.
  scaleway_test_ssh_keys = flatten([
    for pubkey in [
      "freswa.pub",
      "jelle.pub",
      "svenstaro.pub",
      "anthraxx.pub",
      "klausenbusk.pub",
      "artafinde.pub",
      "gromit.pub",
      "antiz.pub",
      ] : [
      for line in split("\n", file("${path.module}/../pubkeys/${pubkey}")) :
      trimspace(line) if trimspace(line) != ""
    ]
  ])
}

resource "scaleway_instance_ip" "test_ipv4" {
}

resource "scaleway_instance_server" "test" {
  name  = "scaleway-test"
  type  = "BASIC3-X2C-4G"
  image = "ubuntu_noble"
  ip_id = scaleway_instance_ip.test_ipv4.id

  user_data = {
    cloud-init = <<-EOT
      #cloud-config
      ssh_authorized_keys:
      ${join("\n", [for key in local.scaleway_test_ssh_keys : "  - ${key}"])}
    EOT
  }
}
