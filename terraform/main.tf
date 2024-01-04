terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.25.1"
    }
  }
}

provider "kubernetes" {
  config_path    = "../kubeconfig"
  config_context = "default"
  ignore_annotations = [
    "kubed\\.appscode\\.com/origin"
  ]
  ignore_labels = [
    "kubed.+"
  ]
}

module "secrets_storage" {
  source = "./secrets_storage"
  homelab_project_id = "${var.homelab_project_prefix}-external-secrets-op"
  email_username = var.email_username
  email_password = var.email_password
  alertmanager_config = var.alertmanager_config
  tailscale_authkey = var.tailscale_authkey
}

module "dns" {
  source = "./dns"
  homelab_domain = var.homelab_domain
  homelab_account_id = var.homelab_account_id
  cloudflare_api_token = var.cloudflare_api_token
  cloudflare_email = var.cloudflare_email
}

module "idp" {
  source = "./idp"
  authentik_bootstrap_token = var.authentik_token
}

module "backups" {
  source = "./backups"
  b2_app_key = var.b2_app_key
  b2_app_key_id = var.b2_app_key_id
  b2_app_key_name = var.b2_app_key_name
  homelab_project_id = "${var.homelab_project_prefix}-backups"

  email_username = var.email_username
  email_password = var.email_password
}
