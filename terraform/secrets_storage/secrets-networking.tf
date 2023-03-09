
locals {
  networking_secrets = {
  }
}


resource "google_secret_manager_secret" "networking" {
  for_each = local.networking_secrets
  secret_id = each.key

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "networking_version" {
  for_each = local.networking_secrets

  secret = google_secret_manager_secret.networking[each.key].id

  secret_data = each.value //.secret
}
