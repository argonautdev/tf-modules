##To work with GCP services using either console, or progrmatically, you must first enable API's. 
##The following Module allows to enable All APIs to work with Bastion. 
module "enabled_google_apis" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 11.3"

  project_id                  = var.project_id
  disable_services_on_destroy = false

  activate_apis = [
    "storage-api.googleapis.com", ##Cloud Storage API
    "storage.googleapis.com" ##Cloud Storage
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

module "gcs_bucket" {
  #source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  depends_on = [null_resource.after]
  source = "terraform-google-modules/cloud-storage/google"
  version = "3.2.0"
  project_id  = var.project_id
  prefix = var.prefix
  names = var.names
  location = var.location
  storage_class = var.storage_class
  force_destroy = var.force_destroy
  versioning = var.versioning
  encryption_key_names = var.encryption_key_names
  # encryption = var.encryption
  bucket_policy_only = var.bucket_policy_only
  labels = merge(var.labels, var.default_labels)
  lifecycle_rules = var.lifecycle_rules
  cors = var.cors
  website = var.website
  retention_policy = var.retention_policy
  logging = var.logging
  set_admin_roles = var.set_admin_roles
  bucket_admins = var.bucket_admins
  set_creator_roles = var.set_creator_roles
  bucket_creators = var.bucket_creators
  set_viewer_roles = var.set_viewer_roles
  bucket_viewers = var.bucket_viewers
  set_hmac_key_admin_roles = var.set_hmac_key_admin_roles
  bucket_hmac_key_admins = var.bucket_hmac_key_admins
  set_storage_admin_roles = var.set_storage_admin_roles
  bucket_storage_admins = var.bucket_storage_admins
}

resource "google_storage_bucket_iam_binding" "make_bucket_public" {
  depends_on = [module.gcs_bucket]
  count = var.bucket_access_level == "public" ? 1: 0
  bucket = element(var.names, 0) 
  role        = "roles/storage.objectViewer"

  members = [
    "allUsers"
  ]
}