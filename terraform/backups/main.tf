terraform {
  required_version = ">= 1.0.0"
  required_providers {
    b2 = {
      source = "Backblaze/b2"
    }
  }
}

provider "b2" {
  application_key = var.b2_app_key
  application_key_id = var.b2_app_key_id
}
