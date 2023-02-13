##To work with GCP services using either console, or progrmatically, you must first enable API's. 
##The following Module allows to enable All APIs to work with Bastion. 
module "enabled_google_apis" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 11.3"

  project_id                  = var.project_id
  disable_services_on_destroy = false

  activate_apis = [
    "composer.googleapis.com", ##Cloud Composer API
  ]
}

module "composer_v2" {
  source = "terraform-google-modules/composer/google//modules/create_environment_v2"
  version = "v3.4.0"
  project_id = var.project_id
  composer_env_name = var.composer_env_name
  region  = var.region
  image_version = var.image_version
  network    = var.vpc_network_name
  subnetwork = var.subnetwork
  environment_size = var.environment_size
}