resource "b2_application_key" "backup_key" {
  key_name     = "homelab-k8s-volsync"
  capabilities = [
    "listAllBucketNames",
    "listBuckets",
    "readBuckets",
    "writeBuckets",
    "deleteBuckets",
    "readBucketEncryption",
    "readBucketReplications",
    "readBucketRetentions",
    "writeBucketEncryption",
    "writeBucketReplications",
    "writeBucketRetentions",
    "listFiles",
    "readFiles",
    "shareFiles",
    "writeFiles",
    "deleteFiles"
  ]
}

resource "b2_bucket" "backup_bucket" {
  bucket_name = "homelab-k8s-tcash"
  bucket_type = "allPrivate"
}

