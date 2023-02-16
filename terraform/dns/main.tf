terraform {
  required_providers {
    cloudflare = {
        source = "cloudflare/cloudflare"
    }
  }
}

variable "homelab_account_id" {}
variable "homelab_domain" {}
variable "cloudflare_api_token" {}
variable "cloudflare_email" {}

# resource "cloudflare_zone" "homelab_zone" {
#   account_id = var.homelab_account_id
#   zone       = var.homelab_domain
#   type = "partial"
# }

resource "kubernetes_secret" "cloudflare_secret" {
  metadata {
    name = "cloudflare-secret"
    namespace = "security"
  }

  data = {
    "email" = var.cloudflare_email
    "api-token" = var.cloudflare_api_token
  }
}
