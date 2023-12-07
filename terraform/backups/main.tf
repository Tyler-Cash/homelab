terraform {
  required_version = ">= 1.0.0"
  required_providers {
    b2 = {
      source = "Backblaze/b2"
    }
    google = {
      source = "hashicorp/google"
      version = "5.8.0"
    }
    google-beta = {
      source = "hashicorp/google-beta"
      version = "5.8.0"
    }
  }
}

provider "b2" {
  application_key = var.b2_app_key
  application_key_id = var.b2_app_key_id
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

  project_id = google_project.homelab_backups.project_id

  activate_apis = [
    "storage-component.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ]
}


resource "google_project" "homelab_backups" {
  lifecycle {
    ignore_changes = [org_id]
  }
  name       = "Homelab Backups"
  project_id = var.homelab_project_id
  billing_account = data.google_billing_account.homelab_billing.id
}

data "google_billing_account" "homelab_billing" {
  display_name = "Homelab"
  open         = true
}
