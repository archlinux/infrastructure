terraform {
  required_providers {
    external = {
      source = "hashicorp/external"
    }
    keycloak = {
      source  = "mrparkers/keycloak"
      version = "2.0.0"
    }
  }
  required_version = ">= 0.13"
}
