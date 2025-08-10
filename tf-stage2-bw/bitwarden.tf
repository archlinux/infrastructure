data "external" "vault_vaultwarden" {
  program = ["${path.module}/../misc/get_key.py", "${path.module}/../misc/vaults/vault_vaultwarden.yml",
    "vaultwarden_url",
    "vaultwarden_email",
    "vaultwarden_password",
  "--format", "json"]
}

provider "bitwarden" {
  server          = data.external.vault_vaultwarden.result.vaultwarden_url
  email           = data.external.vault_vaultwarden.result.vaultwarden_email
  master_password = data.external.vault_vaultwarden.result.vaultwarden_password

  experimental {
    embedded_client                       = true
    disable_sync_after_write_verification = true
  }
}

data "bitwarden_organization" "arch_linux" {
  search = "Arch Linux"
}

data "bitwarden_org_member" "owner" {
  email           = "root@archlinux.org"
  organization_id = data.bitwarden_organization.arch_linux.id
}
data "bitwarden_org_member" "this" {
  for_each        = { for member in var.members : member.email => member }
  email           = each.key
  organization_id = data.bitwarden_organization.arch_linux.id
}

resource "bitwarden_org_collection" "this" {
  for_each        = { for collection in var.collections : collection.name => collection }
  name            = each.key
  organization_id = data.bitwarden_organization.arch_linux.id

  dynamic "member" {
    for_each = { for member in var.members : member.email => member if !member.junior || contains(each.value.members, member.email) }
    content {
      id             = data.bitwarden_org_member.this[member.key].id
      hide_passwords = false
      read_only      = false
      manage         = false
    }
  }

  member {
    id     = data.bitwarden_org_member.owner.id
    manage = true
  }
}
