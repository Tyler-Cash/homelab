variable "homelab_account_id" {}
variable "homelab_domain" {}
variable "cloudflare_email" {}
variable "cloudflare_api_token" {
    sensitive = true
}