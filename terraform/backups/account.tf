resource "google_service_account" "backup_operator" {
  account_id   = "homelab-backup-k8s-account"
  display_name = "homelab-backup-k8s-account"
  project     = google_project.homelab_backups.project_id
}
resource "google_service_account_key" "backup_operator_key" {
  service_account_id = google_service_account.backup_operator.email
}

data "google_iam_policy" "secrets_k8s_policy" {
  binding {
    role = "roles/editor"
    members = [
      "serviceAccount:${google_service_account.backup_operator.email}"
    ]
  }
  binding {
    role = "roles/browser"
    members = [
      "serviceAccount:${google_service_account.backup_operator.email}"
    ]
  }
}

resource "google_project_iam_policy" "project" {
  project     = google_project.homelab_backups.project_id
  policy_data = data.google_iam_policy.secrets_k8s_policy.policy_data
}
