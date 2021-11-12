terraform {
  required_version = ">= 1.0.0"
}

provider "google" {
    credentials = var.gcp_credentials
  project     = var.gcp_project
  region      = var.gcp_region
  zone = var.gcp_zone
}