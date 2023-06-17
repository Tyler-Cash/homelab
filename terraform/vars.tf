output "authentik_password" {
  value = module.secrets_storage.authentik_admin_password
  sensitive = true
}

variable "homelab_domain" {
    type = string
}

variable "homelab_account_id" {
    type = string
}

variable "homelab_project_prefix" {
    type = string
}

variable "authentik_token" {
    type = string
    sensitive = true
}

variable "cloudflare_api_token" {
    type = string
    sensitive = true
}

variable "cloudflare_email" {
    type = string
}

variable "b2_app_key_id" {
    type = string
    sensitive = true

}

variable "b2_app_key_name" {
    type = string
}

variable "b2_app_key" {
    type = string
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

variable "tailscale_authkey" {
  sensitive = true
}
