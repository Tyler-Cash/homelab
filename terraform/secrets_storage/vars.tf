output "authentik_token" {
  value = random_password.authentik_bootstrap_token.result
}

variable "foundry_username" {
  type = string
  sensitive = true
}

variable "foundry_password" {
  type = string
  sensitive = true
}

output "authentik_admin_password" {
  value = random_password.authentik_bootstrap_password.result
}

variable "secrets_namespace" {
  description = "namespace where external secrets operator will be deployed"
  type        = string
  default     = "security"
}

variable "homelab_project_id" {}

variable "plex_claim" {
  sensitive = true
}

variable "email_username" {
  sensitive = true # Sensitive as value is a key, not a username
}

variable "email_password" {
  sensitive = true
}

variable "alertmanager_config" {
  sensitive = true
}

variable "tylerbot_config" {
  sensitive = true
}

variable "tailscale_authkey" {
  sensitive = true
}
