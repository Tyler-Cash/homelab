resource "google_storage_bucket" "backup-bucket" {
  name                        = "homelab-backups-k8s"
  location                    = "ASIA-SOUTHEAST1"
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  project                     = google_project.homelab_backups.project_id
  autoclass {
    enabled                = true
    terminal_storage_class = "NEARLINE"
  }
}
