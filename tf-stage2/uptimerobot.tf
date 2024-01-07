# When deleting a resource outside of terraform, the provider errors out and a
# resource has to be manually deleted in terraform, see:
# https://github.com/louy/terraform-provider-uptimerobot/issues/82

data "external" "vault_uptimerobot" {
  program = ["${path.module}/../misc/get_key.py", "${path.module}/../group_vars/all/vault_uptimerobot.yml",
    "vault_uptimerobot_api_key",
    "vault_uptimerobot_alert_contact",
  "--format", "json"]
}

provider "uptimerobot" {
  api_key = data.external.vault_uptimerobot.result.vault_uptimerobot_api_key
}

data "uptimerobot_account" "account" {}

locals {
  archlinux_org_monitor = {
    "Accounts"         = "https://accounts.archlinux.org"
    "AUR"              = "https://aur.archlinux.org"
    "Forum"            = "https://bbs.archlinux.org"
    "Gitlab"           = "https://gitlab.archlinux.org"
    "Man"              = "https://man.archlinux.org"
    "Security Tracker" = "https://security.archlinux.org"
    "Website"          = "https://archlinux.org"
    "Wiki"             = "https://wiki.archlinux.org"
  }
}

resource "uptimerobot_monitor" "uptimerobot_monitor_archlinux" {
  for_each = local.archlinux_org_monitor

  friendly_name = each.key
  type          = "http"
  url           = each.value
  interval      = 300
}
