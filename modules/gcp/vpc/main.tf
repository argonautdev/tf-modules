module "enabled_google_apis" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 11.3"

  project_id                  = var.project_id
  disable_services_on_destroy = false

  activate_apis = [
    "servicenetworking.googleapis.com",
    "compute.googleapis.com"
  ]
}

module "vpc" {
  source           = "terraform-google-modules/network/google"
  version          = "~> 4.0"
  project_id       = var.project_id
  network_name     = var.network_name
  description      = var.description
  subnets          = var.subnets
  # secondary_ranges = var.secondary_ranges ##Removing this as this is not required at the moment.
}

################################
# Nat and Routetable creation  #
################################
module "cloud_router" {
  depends_on  = [module.vpc]
  source      = "terraform-google-modules/cloud-router/google"
  version     = "2.0.0"
  name        = var.router_name
  description = var.router_description
  project     = var.project_id
  region      = var.region
  network     = var.network_name
  nats        = var.nats
}

########################################
# Enabling Private service connection ##
########################################
/*IMP: Please read doc carefully about Private service access */
## https://cloud.google.com/vpc/docs/configure-private-services-access?authuser=1&_ga=2.86912664.-1808336238.1654844270&_gac=1.153215690.1656639899.CjwKCAjwk_WVBhBZEiwAUHQCmQzQRuTvjYfO5ZBs1IQh0OVGfrsVSqUAoisb3j932g0yfSPw4S5qNhoC1kMQAvD_BwE

/* Allocate IP Address range */
module "private-service-access" {
  depends_on = [module.vpc]
  source      = "GoogleCloudPlatform/sql-db/google//modules/private_service_access"
  version = "11.0.0"
  project_id  = var.project_id
  vpc_network = var.network_name
  description = "private service access for vpc ${var.network_name}"
  prefix_length = var.prefix_length
}


