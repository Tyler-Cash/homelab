resource "google_service_account" "external_secrets_operator" {
  account_id   = "homelab-k8s-account"
  display_name = "homelab-k8s-account"
}
resource "google_service_account_key" "external_secrets_operator_key" {
  service_account_id = google_service_account.external_secrets_operator.email
}
