resource "random_password" "tandoor_secret_key" {
  length           = 50
  special          = true
}

locals {
  media_secrets = {
    "media-tandoor-secret-key" = {secret = random_password.tandoor_secret_key.result}
  }
}


resource "google_secret_manager_secret" "media" {
  for_each = local.media_secrets
  secret_id = each.key

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "media_version" {
  for_each = local.media_secrets
  secret = google_secret_manager_secret.media[each.key].id
  secret_data = each.value.secret
}
