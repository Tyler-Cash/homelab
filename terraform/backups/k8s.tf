resource "kubernetes_config_map" "restic-config" {
  metadata {
    name = "restic-config"
    # Create in Kyverno's namespace so kyverno can propogate it as needed
    namespace = "kyverno"
  }

  data = {
    RESTIC_REPOSITORY = "gs:${google_storage_bucket.backup-bucket.name}"
    # Merely to complicate unapproved access to backup files
    # Targeted attacks and data access would be successful
    RESTIC_PASSWORD = "H8%G3SN!MJb^65rBNk4@Ug4ZASRfsD*JKwQPi8aehh^2tq*@gyUJ@W2z4T#o&cQD5ry*GdYHJ&"
    GOOGLE_PROJECT_ID = google_project.homelab_backups.id
    GOOGLE_APPLICATION_CREDENTIALS = base64decode(google_service_account_key.backup_operator_key.private_key)
  }
}


resource "kubernetes_secret" "cloudnativepg-secrets" {
  metadata {
    name = "cloudnativepg-secrets"
    namespace = "security"
  }

  data = {
    destination = "${google_storage_bucket.backup-bucket.url}"
    GOOGLE_PROJECT_ID = google_project.homelab_backups.id
    GOOGLE_APPLICATION_CREDENTIALS = base64decode(google_service_account_key.backup_operator_key.private_key)
  }
}
