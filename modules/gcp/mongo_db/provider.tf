terraform {
  required_version = ">= 1.0"
  experiments = [module_variable_optional_attrs]
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.22.0"
    }
    mongodbatlas = {
      source = "mongodb/mongodbatlas"
      version = "1.2.0"
    }
  }
}

##Provider reference
#https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference#configuration-reference
##Default Tag limited to AWS Provider which is not availble in GCP. Hence commented out.
##Region Codes: https://cloud.google.com/about/locations#americas
provider "google" {
  project = var.project_id
  region  = var.region
}

provider "mongodbatlas" {
  public_key  = var.atlas_public_key
  private_key = var.atlas_private_key
}