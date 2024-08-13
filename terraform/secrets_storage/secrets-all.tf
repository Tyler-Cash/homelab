resource "random_password" "tandoor_secret_key" {
  length           = 50
  special          = true
}

resource "random_password" "authentik_secret_key" {
  length           = 100
  special          = true
}

resource "random_password" "authentik_bootstrap_password" {
  length           = 100
  special          = true
}

resource "random_password" "authentik_bootstrap_token" {
  length           = 100
  special          = true
}

locals {
  all_secrets = {
    "tandoor" = {
      "secret-key" = random_password.tandoor_secret_key.result
    }
    "alertmanager" = {
      "alertmanager.yaml" = var.alertmanager_config
    }
    "tylerbot" = {
      "application-prod.yaml" = var.tylerbot_config
    }
    "authentik" = {
      "email-username" = var.email_username
      "email-password" = var.email_password
      "secret-key" = random_password.authentik_secret_key.result
      "bootstrap-password" = random_password.authentik_bootstrap_password.result
      "bootstrap-token" = random_password.authentik_bootstrap_token.result
    }
  }
}


resource "google_secret_manager_secret" "all" {
  secret_id = "all_secrets"

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "all_version" {
  secret = google_secret_manager_secret.all.id
  secret_data = jsonencode(local.all_secrets)
}
