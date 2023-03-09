resource "kubernetes_config_map" "restic-config" {
  metadata {
    name = "restic-config"
    namespace = "security"
  }

  data = {
    RESTIC_REPOSITORY = "s3:s3.us-east-005.backblazeb2.com/${b2_bucket.backup_bucket.bucket_name}"
    RESTIC_PASSWORD = "my-secure-restic-password"

    //noinspection HILUnresolvedReference
    AWS_ACCESS_KEY_ID = b2_application_key.backup_key.application_key_id
    //noinspection HILUnresolvedReference
    AWS_SECRET_ACCESS_KEY = b2_application_key.backup_key.application_key
    AWS_DEFAULT_REGION = "us-east-005"
  }
}

resource "kubernetes_secret" "cloudnativepg-secrets" {
  metadata {
    name = "cloudnativepg-secrets"
    namespace = "security"
  }

  data = {
    destination = "s3://s3.us-east-005.backblazeb2.com/${b2_bucket.backup_bucket.bucket_name}"
    //noinspection HILUnresolvedReference
    AWS_ACCESS_KEY_ID = b2_application_key.backup_key.application_key_id
    //noinspection HILUnresolvedReference
    AWS_SECRET_ACCESS_KEY = b2_application_key.backup_key.application_key
  }
}
