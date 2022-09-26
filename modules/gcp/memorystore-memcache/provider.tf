terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.22.0"
    }
  }
}

##Provider reference
#https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference#configuration-reference
##Region Codes: https://cloud.google.com/about/locations#americas
provider "google" {
  project = var.project_id
  region  = var.region
}