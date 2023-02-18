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
  security_secrets = {
    "security-authentik-email-username" = {secret = var.email_username}
    "security-authentik-email-password" = {secret = var.email_password}
    "security-authentik-secret-key" = {secret = random_password.authentik_secret_key.result}
    "security-authentik-bootstrap-password" = {secret = random_password.authentik_bootstrap_password.result}
    "security-authentik-bootstrap-token" = {secret = random_password.authentik_bootstrap_token.result}
  }
}


resource "google_secret_manager_secret" "s" {
  for_each = local.security_secrets
  secret_id = each.key

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "security_version" {
  for_each = local.security_secrets

  secret = google_secret_manager_secret.s[each.key].id

  secret_data = each.value.secret
}
