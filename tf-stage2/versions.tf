terraform {
  required_providers {
    external = {
      source = "hashicorp/external"
    }
    keycloak = {
      source = "mrparkers/keycloak"
    }
    uptimerobot = {
      source = "vexxhost/uptimerobot"
    }
  }
  required_version = ">= 0.13"
}
