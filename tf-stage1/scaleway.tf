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
