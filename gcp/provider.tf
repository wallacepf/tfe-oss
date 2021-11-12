terraform {
  required_version = ">= 0.11.1"
}

provider "google" {
  project     = "${var.gcp_project}"
  region      = "${var.gcp_region}"
}