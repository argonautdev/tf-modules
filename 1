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

resource "google_service_account" "custom_service_account" {
  account_id   = "${var.composer_env_name}-svc"
  project = var.project_id
  display_name = "Custom Service Account"
}

resource "google_project_iam_member" "custom_service_account" {
  depends_on = [google_service_account.custom_service_account]
  project  = var.project_id
  member   = format("serviceAccount:%s", google_service_account.custom_service_account.email)
  // Role for Public IP environments
  role     = "roles/composer.worker"
}

data "google_project" "project" {
  project_id = var.project_id
}

resource "google_service_account_iam_member" "custom_service_account" {
  service_account_id = google_service_account.custom_service_account.name
  role = "roles/composer.ServiceAgentV2Ext"
  member = "serviceAccount:service-${data.google_project.project.number}@cloudcomposer-accounts.iam.gserviceaccount.com"
}


module "composer_v2" {
  depends_on = [module.enabled_google_apis, google_service_account.custom_service_account, google_service_account_iam_member.custom_service_account]
  source = "terraform-google-modules/composer/google//modules/create_environment_v2"
  version = "v3.4.0"
  project_id = var.project_id
  composer_env_name = var.composer_env_name
  region  = var.region
  image_version = var.image_version
  network    = var.vpc_network_name
  subnetwork = var.subnetwork
  environment_size = var.environment_size
  composer_service_account = google_service_account.custom_service_account.email
  grant_sa_agent_permission = var.grant_sa_agent_permission
}
