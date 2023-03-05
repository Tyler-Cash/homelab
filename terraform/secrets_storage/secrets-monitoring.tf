
locals {
  monitoring_secrets = {
    "monitoring-alertmanager-yaml" = {secret = var.alertmanager_config}
  }
}


resource "google_secret_manager_secret" "monitoring" {
  for_each = local.monitoring_secrets
  secret_id = each.key

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "monitoring_version" {
  for_each = local.monitoring_secrets

  secret = google_secret_manager_secret.monitoring[each.key].id

  secret_data = each.value.secret
}
