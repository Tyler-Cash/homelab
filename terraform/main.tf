terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.18.0"
    }
    google = {
      source = "hashicorp/google"
      version = "4.53.1"
    }
  }
}

provider "google" {
  project = var.homelab_project_id
  region = "australia-southeast1"
}

provider "kubernetes" {
  config_path    = "../kubeconfig"
  config_context = "default"
}

provider "cloudflare" {
}

module "secrets_storage" {
  source = "./secrets_storage"
  homelab_project_id = var.homelab_project_id
}
module "dns" {
  source = "./dns"
  homelab_domain = var.homelab_domain
  homelab_account_id = var.homelab_account_id
  cloudflare_api_token = var.cloudflare_api_token
  cloudflare_email = var.cloudflare_email
}

variable "homelab_domain" {
    type = string
}

variable "homelab_account_id" {
    type = string
}
variable "homelab_project_id" {
    type = string
}
variable "cloudflare_api_token" {
    type = string
}
variable "cloudflare_email" {
    type = string
}
