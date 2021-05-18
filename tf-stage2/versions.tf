terraform {
  required_providers {
    external = {
      source = "hashicorp/external"
    }
    keycloak = {
      source  = "mrparkers/keycloak"
      version = "2.0.0"
    }
    uptimerobot = {
      source  = "louy/uptimerobot"
      version = "0.5.1"
    }
  }
  required_version = ">= 0.13"
}
