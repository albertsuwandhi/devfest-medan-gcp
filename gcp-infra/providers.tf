terraform {
  required_version = ">1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.59.0"
    }
  }
}

provider "google" {
  project = "gdg-medan-devfest"
  region  = "asia-southeast2"
  zone    = "asia-southeast2-a"
}