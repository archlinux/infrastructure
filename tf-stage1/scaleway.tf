data "external" "vault_scaleway" {
  program = [
    "${path.module}/../misc/get_key.py", "${path.module}/../misc/vaults/vault_scaleway.yml",
    "scaleway_api_access_key",
    "scaleway_api_secret_key",
    "scaleway_organization_id",
    "scaleway_project_id",
    "scaleway_username",
    "--format", "json"
  ]
}

provider "scaleway" {
  access_key      = data.external.vault_scaleway.result.scaleway_api_access_key
  secret_key      = data.external.vault_scaleway.result.scaleway_api_secret_key
  organization_id = data.external.vault_scaleway.result.scaleway_organization_id
  project_id      = data.external.vault_scaleway.result.scaleway_project_id
}

# Monthly spending budget for the whole Scaleway organization.
resource "scaleway_billing_budget" "scaleway_account_limit" {
  consumption_limit = 1000 # in €, the provider docs wrongly claim cents
}

resource "scaleway_billing_budget_alert" "scaleway_account_limit" {
  budget_id = scaleway_billing_budget.scaleway_account_limit.id
  threshold = 80 # in percent, i.e. 800€
}

resource "scaleway_billing_budget_alert_notification" "email" {
  budget_alert_id = scaleway_billing_budget_alert.scaleway_account_limit.id
  email_addresses = [data.external.vault_scaleway.result.scaleway_username]
}

locals {
  scaleway_servers     = [for server in var.servers : server if server.provider == "scaleway"]
  scaleway_servers_map = { for server in local.scaleway_servers : server.fqdn => server }
  scaleway_zones       = distinct([for server in local.scaleway_servers : server.zone])
  scaleway_types       = distinct([for server in local.scaleway_servers : "${server.type}/${server.zone}/${server.subscription_period}"])
}

data "scaleway_baremetal_offer" "this" {
  for_each = { for type in local.scaleway_types : type => split("/", type) }

  name                = each.value[0]
  subscription_period = each.value[2]
  zone                = each.value[1]
}

data "scaleway_baremetal_os" "this" {
  for_each = toset(local.scaleway_zones)

  name    = "Custom install"
  version = "via Remote access"
  zone    = each.key
}

data "scaleway_baremetal_option" "this" {
  for_each = toset(local.scaleway_zones)

  name = "Public Bandwidth 1Gbps"
  zone = each.key
}

resource "scaleway_baremetal_server" "this" {
  for_each = local.scaleway_servers_map

  name        = replace(each.value.fqdn, ".", "-")
  description = each.value.fqdn
  offer       = data.scaleway_baremetal_offer.this[format("%s/%s/%s", each.value.type, each.value.zone, each.value.subscription_period)].offer_id
  os          = data.scaleway_baremetal_os.this[each.value.zone].os_id
  zone        = each.value.zone
  protected   = true

  options {
    id = data.scaleway_baremetal_option.this[each.value.zone].option_id
  }

  lifecycle {
    action_trigger {
      events  = [after_create]
      actions = [action.scaleway_baremetal_server_action.this[each.key]]
    }
  }
}

action "scaleway_baremetal_server_action" "this" {
  for_each = scaleway_baremetal_server.this

  config {
    server_id = each.value.id
    action    = "reboot"
    boot_type = "rescue"
    wait      = true
    zone      = each.value.zone
  }
}

resource "hcloud_zone_rrset" "scaleway_a" {
  for_each = scaleway_baremetal_server.this

  zone = regex("[^\\.]+\\.[^\\.]+$", each.key)
  name = regex("(.+)\\.[^\\.]+\\.[^\\.]+$", each.key)[0]
  type = "A"
  records = [
    { value = each.value.ipv4[0].address },
  ]
}

resource "hcloud_zone_rrset" "scaleway_aaaa" {
  for_each = scaleway_baremetal_server.this

  zone = regex("[^\\.]+\\.[^\\.]+$", each.key)
  name = regex("(.+)\\.[^\\.]+\\.[^\\.]+$", each.key)[0]
  type = "AAAA"
  records = [
    { value = each.value.ipv6[0].address },
  ]
}

resource "hcloud_zone_rrset" "scaleway_https" {
  for_each = {
    for k, v in local.scaleway_servers_map : k => merge(v, scaleway_baremetal_server.this[k]) if try(v.http3, false)
  }

  zone = regex("[^\\.]+\\.[^\\.]+$", each.key)
  name = regex("(.+)\\.[^\\.]+\\.[^\\.]+$", each.key)[0]
  type = "HTTPS"
  records = [
    { value = "1 . alpn=h2,h3 ipv4hint=${each.value.ipv4[0].address} ipv6hint=${each.value.ipv6[0].address}" },
  ]
}
