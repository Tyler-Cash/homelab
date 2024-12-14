
resource "google_project" "homelab_secrets_storage" {
  lifecycle {
    ignore_changes = [org_id]
  }

  name       = "Homelab External Secrets Op"
  project_id = var.homelab_project_id
  billing_account = data.google_billing_account.homelab_billing.id
}

data "google_billing_account" "homelab_billing" {
  display_name = "Homelab"
  open         = true
}
