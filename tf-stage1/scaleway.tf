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
