terraform {
  required_providers {
    external = {
      source = "hashicorp/external"
    }
    keycloak = {
      source = "mrparkers/keycloak"
    }
    uptimerobot = {
      source = "louy/uptimerobot"
    }
  }
  required_version = ">= 0.13"
}
