module "secret-manager" {
  source  = "GoogleCloudPlatform/secret-manager/google"
  version = "~> 0.5"
  project_id = google_project.homelab_secrets_storage.id
}

resource "google_kms_key_ring" "homelab_keyring" {
  name     = "homelab_keyring"
  location = "global"
}

resource "google_kms_crypto_key" "homelab_crypto_key" {
  name            = "homelab_crypto_key"
  key_ring        = google_kms_key_ring.homelab_keyring.id
  rotation_period = "31536000s"
  lifecycle {
    prevent_destroy = true
  }
}
