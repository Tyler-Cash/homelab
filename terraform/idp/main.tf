terraform {
  required_providers {
    authentik = {
      source = "goauthentik/authentik"
      version = "2024.10.1"
    }
  }
}

provider "authentik" {
    url   = "https://authentik.k8s.tylercash.dev"
    token = var.authentik_bootstrap_token
}

data "authentik_certificate_key_pair" "generated" {
  name = "authentik Self-signed Certificate"
}
