##To work with GCP services using either console, or progrmatically, you must first enable API's. 
##The following Module allows to enable All APIs to work with Bastion. 
module "enabled_google_apis" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 11.3"

  project_id                  = var.project_id
  disable_services_on_destroy = false

  activate_apis = [
    "bigquery.googleapis.com", ##Big Query JSON API
    "bigquerydatatransfer.googleapis.com", ##Big Query Data transfers API
    "biglake.googleapis.com" ##BigQuerys BigLake API
  ]
}

resource "null_resource" "previous" {
  depends_on = [module.enabled_google_apis]
  provisioner "local-exec" {
    command = "echo \"waiting for 30 seconds before starting resources creation\""
  }
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [module.enabled_google_apis, null_resource.previous]
  create_duration = "30s"
}

resource "null_resource" "after" {
  depends_on = [module.enabled_google_apis, time_sleep.wait_30_seconds]
  provisioner "local-exec" {
    command = "echo \"wait is over!!! starting resources creation\""
  }
}

module "bigquery" {
  depends_on = [module.enabled_google_apis]
  source  = "terraform-google-modules/bigquery/google"
  version = "v5.4.3"

  dataset_id                  = var.dataset_name
  dataset_name                = var.dataset_name
  description                 = var.description
  project_id                  = var.project_id
  location                    = var.region
  default_table_expiration_ms = var.default_table_expiration_ms
}