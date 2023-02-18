resource "b2_application_key" "backup_key" {
  key_name     = "homelab-k8s-volsync"
  capabilities = ["writeFiles", "deleteFiles", "listFiles", "readFiles", "readBuckets", "listAllBucketNames", "readBucketRetentions"]
}

resource "b2_bucket" "backup_bucket" {
  bucket_name = "homelab-k8s-tcash"
  bucket_type = "allPrivate"
}

