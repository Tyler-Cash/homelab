variable "secrets_namespace" {
  description = "namespace where external secrets operator will be deployed"
  type        = string
  default     = "security"
}
