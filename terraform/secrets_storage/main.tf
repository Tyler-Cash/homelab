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

module "project-services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "17.1"

  project_id = google_project.homelab_secrets_storage.project_id

  activate_apis = [
    "secretmanager.googleapis.com",
    "cloudkms.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ]
}

