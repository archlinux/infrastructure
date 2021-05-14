# When deleting a resource outside of terraform, the provider errors out and a
# resource has to be manually deleted in terraform, see:
# https://github.com/louy/terraform-provider-uptimerobot/issues/82

data "external" "vault_uptimerobot" {
  program = ["${path.module}/../misc/get_key.py", "group_vars/all/vault_uptimerobot.yml",
    "vault_uptimerobot_api_key",
    "vault_uptimerobot_alert_contact",
  "--format", "json"]
}

provider "uptimerobot" {
  api_key = data.external.vault_uptimerobot.result.vault_uptimerobot_api_key
}

data "uptimerobot_account" "account" {}

data "uptimerobot_alert_contact" "default_alert_contact" {
  friendly_name = data.external.vault_uptimerobot.result.vault_uptimerobot_alert_contact
}

locals {
  archlinux_org_monitor = {
    "Wiki"             = "https://wiki.archlinux.org"
    "Website"          = "https://archlinux.org"
    "Security Tracker" = "https://security.archlinux.org"
    "Gitlab"           = "https://gitlab.archlinux.org"
    "Forum"            = "https://bbs.archlinux.org"
    "Bugtracker"       = "https://bugs.archlinux.org"
    "AUR"              = "https://aur.archlinux.org"
    "Man"              = "https://man.archlinux.org"
  }
}

resource "uptimerobot_monitor" "uptimerobot_monitor_archlinux" {
  for_each = local.archlinux_org_monitor

  friendly_name = each.key
  type          = "http"
  url           = each.value
  interval      = 60

  alert_contact {
    id = data.uptimerobot_alert_contact.default_alert_contact.id
  }
}
