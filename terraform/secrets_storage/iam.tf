data "google_iam_policy" "secrets_k8s_policy" {
  binding {
    role = "roles/secretmanager.viewer"
    members = [
      "serviceAccount:${google_service_account.external_secrets_operator.email}"
    ]
  }
  binding {
    role = "roles/secretmanager.secretAccessor"
    members = [
      "serviceAccount:${google_service_account.external_secrets_operator.email}"
    ]
  }
  binding {
    role = "roles/browser"
    members = [
      "serviceAccount:${google_service_account.external_secrets_operator.email}"
    ]
  }
}

resource "google_project_iam_policy" "project" {
  project     = google_project.homelab_secrets_storage.project_id
  policy_data = data.google_iam_policy.secrets_k8s_policy.policy_data
}
