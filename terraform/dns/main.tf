terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}

resource "kubernetes_secret" "cloudflare_secret" {
  metadata {
    name = "cloudflare-secret"
    namespace = "security"
    annotations = {
      "kubed.appscode.com/sync"= ""
    }
  }

  data = {
    "email" = var.cloudflare_email
    "api-token" = var.cloudflare_api_token
  }
}
