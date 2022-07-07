##To work with GCP services using either console, or progrmatically, you must first enable API's. 
##The following Module allows to enable All APIs to work with Bastion. 
module "enabled_google_apis" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 11.3"

  project_id                  = var.project_id
  disable_services_on_destroy = false

  activate_apis = [
    "storage-api.googleapis.com",
    "iap.googleapis.com",
    "compute.googleapis.com",
    "oslogin.googleapis.com"
  ]
}

/* Zone for deploying VM */
locals {
  bastion_host_az = format("%s-a", var.region)
}

data "template_file" "startup_script" {
  template = <<-EOF
  sudo apt-get update -y
  sudo apt-get install -y tinyproxy
  EOF
}

##########################################################################
# OS Login enables to connect vms ( i.e ssh ) to instances using
# IAM Identities ( SA Names, IAM UserNames)
# So, the following service account we for logging ( SSH ) to bastion host
# If   
##########################################################################

locals {
  project_roles = [
    "roles/compute.osAdminLogin",
    "roles/iam.serviceAccountUser"
  ]
}


# module "bastion_oslogin_sa" {
#   source        = "terraform-google-modules/service-accounts/google"
#   # version       = "4.1.1"
#   version       = "~> 3.0"
#   project_id    = var.project_id
#   prefix        = "${var.bastion_host_name}-oslogin-sa"
#   description   = "${var.bastion_host_name}-oslogin-sa"
#   generate_keys = true
#   project_roles = [
#     "${var.project_id}=>roles/compute.osAdminLogin",
#     "${var.project_id}=>roles/iam.serviceAccountUser"
#   ]
# }

resource "google_project_iam_member" "add_sa_to_project" {
  project = var.project_id
  role    = "roles/owner"
  member  = "serviceAccount:cross-project-testing@fmtestiedeployment.iam.gserviceaccount.com"
}


resource "google_service_account" "bastion_oslogin_sa" {
  account_id   = "${var.bastion_host_name}-ssh-sa"
  display_name = "${var.bastion_host_name}-ssh-sa"
  description  = "service account to ssh into ${var.bastion_host_name}"
  project      = var.project_id
}

resource "google_project_iam_member" "project" {
  count   = length(local.project_roles)
  project = var.project_id
  role    = local.project_roles[count.index]
  member  = "serviceAccount:${google_service_account.bastion_oslogin_sa.email}"
}

module "bastion" {
  source                             = "terraform-google-modules/bastion-host/google"
  version                            = "5.0.0"
  project                            = var.project_id
  host_project                       = var.project_id
  network                            = var.network
  subnet                             = var.subnet
  name                               = var.bastion_host_name
  zone                               = local.bastion_host_az
  image_project                      = var.image_project
  image_family                       = var.image_family
  machine_type                       = var.machine_type
  disk_type                          = var.disk_type
  disk_size_gb                       = var.disk_size_gb
  scopes                             = var.scopes
  members                            = concat(["serviceAccount:${google_service_account.bastion_oslogin_sa.email}"], var.members)
  service_account_name               = var.service_account_name
  service_account_roles              = var.service_account_roles
  service_account_roles_supplemental = var.service_account_roles_supplemental
  startup_script                     = data.template_file.startup_script.rendered
  fw_name_allow_ssh_from_iap         = var.fw_name_allow_ssh_from_iap
  shielded_vm                        = var.shielded_vm
  labels                             = var.labels
  metadata = {
    serial-port-enable = true
  }
  external_ip                        = var.external_ip
  access_config                      = var.access_config
  tags = [var.bastion_host_name] ##applying bastion hostname 
}
