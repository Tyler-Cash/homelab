terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.60.0"
    }
    google-beta = {
      source = "hashicorp/google-beta"
      version = "4.59.0"
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
  version = "~> 14.1"

  project_id = google_project.homelab_secrets_storage.project_id

  activate_apis = [
    "secretmanager.googleapis.com",
    "cloudkms.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ]
}
