
locals {
  storage_secrets = {
  }
}


resource "google_secret_manager_secret" "storage" {
  for_each = local.storage_secrets
  secret_id = each.key

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "storage_version" {
  for_each = local.storage_secrets

  secret = google_secret_manager_secret.storage[each.key].id

  secret_data = each.value // .secret
}
