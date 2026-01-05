terraform {
  required_providers {
    external = {
      source = "hashicorp/external"
    }
    keycloak = {
      source = "keycloak/keycloak"
    }
    uptimerobot = {
      source = "vexxhost/uptimerobot"
    }
    fastly = {
      source = "fastly/fastly"
    }
  }
  required_version = ">= 0.13"
}
