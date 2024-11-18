terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.12.0"
    }
    google-beta = {
      source = "hashicorp/google-beta"
      version = "6.11.2"
    }
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
  version = "~> 17.0"

  project_id = google_project.homelab_secrets_storage.project_id

  activate_apis = [
    "secretmanager.googleapis.com",
    "cloudkms.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ]
}
