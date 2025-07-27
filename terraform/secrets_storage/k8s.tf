
resource "kubernetes_secret" "gcpsm-secret" {
  metadata {
    name = "gcpsm-secret"
    namespace = "security"
    labels = {
      type = "gcpsm"
    }
    annotations = {
        "kubed.appscode.com/sync"= ""
    }
  }

  binary_data = {
    "gcp_config" = google_service_account_key.external_secrets_operator_key.private_key
  }
}

resource "kubernetes_manifest" "gcp-clusterstore" {
  manifest = {
    "apiVersion" = "external-secrets.io/v1beta1"
    "kind"       = "ClusterSecretStore"
    "metadata" = {
      "name"      = "gcp-clusterstore"
    }
    "spec" = {
      "provider" = {
        "gcpsm" = {
          "auth" = {
            "secretRef" = {
              "secretAccessKeySecretRef" = {
                "name" = "gcpsm-secret"
                "key" = "gcp_config"
              }
            }
          }
          "projectID" = google_project.homelab_secrets_storage.project_id
        }
      }
    }
  }
}
