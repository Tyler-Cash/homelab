variable "storage_namespace" {
  description = "namespace where external secrets operator will be deployed"
  type        = string
  default     = "storage"
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

variable "homelab_project_id" {}

variable "email_username" {
  sensitive = true # Sensitive as value is a key, not a username
}
variable "email_password" {
  sensitive = true
}
