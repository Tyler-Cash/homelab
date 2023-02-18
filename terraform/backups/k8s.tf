resource "kubernetes_config_map" "restic-config" {
  metadata {
    name = "restic-config"
    namespace = "security"
  }

  data = {
    RESTIC_REPOSITORY = "s3:s3.us-east-005.backblazeb2.com/${b2_bucket.backup_bucket.bucket_name}"
    RESTIC_PASSWORD = "my-secure-restic-password"

    AWS_ACCESS_KEY_ID = b2_application_key.backup_key.application_key_id
    AWS_SECRET_ACCESS_KEY = b2_application_key.backup_key.application_key
    AWS_DEFAULT_REGION = "us-east-005"
  }
}
