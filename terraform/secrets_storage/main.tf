variable "homelab_project_id" {}

terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    google = {
      source = "hashicorp/google"
    }
  }
}

data "google_billing_account" "homelab_billing" {
  display_name = "Homelab"
  open         = true
}

module "project-services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 14.1"

  project_id = google_project.homelab_secrets_storage.project_id

  activate_apis = [
    "secretmanager.googleapis.com",
    "cloudkms.googleapis.com"
  ]
}

resource "google_project" "homelab_secrets_storage" {
  name       = "Homelab External Secrets Op"
  project_id = var.homelab_project_id
  billing_account = data.google_billing_account.homelab_billing.id
}


module "secret-manager" {
  source  = "GoogleCloudPlatform/secret-manager/google"
  version = "~> 0.1"
  project_id = google_project.homelab_secrets_storage.id
}

resource "google_secret_manager_secret" "secret-basic" {
  secret_id = "secret"

  replication {
    user_managed {
      replicas {
        location = "australia-southeast1"
      }
      replicas {
        location = "europe-west3"
      }
    }
  }
}

resource "google_service_account" "external_secrets_operator" {
  account_id   = "homelab-k8s-account"
  display_name = "homelab-k8s-account"
}

resource "google_kms_key_ring" "homelab_keyring" {
  name     = "homelab_keyring"
  location = "global"
}

resource "google_kms_crypto_key" "homelab_crypto_key" {
  name            = "homelab_crypto_key"
  key_ring        = google_kms_key_ring.homelab_keyring.id
  rotation_period = "100000s"
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_kms_crypto_key_iam_member" "homelab_encrypter_decrypter" {
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_service_account.external_secrets_operator.email}"
  crypto_key_id = google_kms_crypto_key.homelab_crypto_key.id
}

resource "google_service_account_key" "external_secrets_operator_key" {
  service_account_id = google_service_account.external_secrets_operator.email
}

resource "kubernetes_secret" "gcpsm-secret" {
  metadata {
    name = "gcpsm-secret"
    namespace = "security"
    labels = {
      type = "gcpsm"
    }
  }

  data = {
    "secret-access-credentials" = base64decode(google_service_account_key.external_secrets_operator_key.private_key)
  }
}

resource "kubernetes_manifest" "gcp-store" {
  manifest = {
    "apiVersion" = "external-secrets.io/v1beta1"
    "kind"       = "ClusterSecretStore"
    "metadata" = {
      "name"      = "gcp-store"
    }
    "spec" = {
      "provider" = { 
        "gcpsm" = {
          "auth" = {
            "secretRef" = {
              "secretAccessKeySecretRef" = {
                "name" = "gcpsm-secret"
                "key" = "secret-access-credentials"
              }
            }
          }
          "projectID" = google_project.homelab_secrets_storage.id
        }
      }
    }
  }
}
