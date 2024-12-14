terraform {
  required_providers {
  }
}

provider "google" {
  project = var.homelab_project_id
  region = "australia-southeast1"
}

provider "google-beta" {
  project = var.homelab_project_id
  region = "australia-southeast1"
}

module "project-factory" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 17.1"

  project_id = google_project.homelab_secrets_storage.project_id

  activate_apis = [
    "secretmanager.googleapis.com",
    "cloudkms.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ]
  billing_account = google_project.homelab_secrets_storage.billing_account
  name            = "Homelab Secrets"
}

