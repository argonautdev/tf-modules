data "mongodbatlas_project" "gcp_atlas" {
  project_id = var.atlas_project_id
}

##Container is Just a VPC
resource "mongodbatlas_network_container" "atlas_container" {
  atlas_cidr_block = var.atlas_vpc_cidr
  project_id       = data.mongodbatlas_project.gcp_atlas.id
  provider_name    = "GCP"
}

data "mongodbatlas_network_container" "atlas_container" {
  container_id = mongodbatlas_network_container.atlas_container.container_id
  project_id   = data.mongodbatlas_project.gcp_atlas.id
}

resource "mongodbatlas_network_peering" "gcp-atlas" {
  project_id             = data.mongodbatlas_project.gcp_atlas.id
  container_id           = mongodbatlas_network_container.atlas_container.container_id
  provider_name          = "GCP"
  gcp_project_id         = var.project_id
  network_name           = var.vpc_network_name
}

##IP Access List entry resource. The access list grants access from IPs, CIDRs or AWS Security Groups (if VPC Peering is enabled) to clusters within the Project.
resource "mongodbatlas_project_ip_access_list" "atlas-ip-access-list-1" {
  project_id = var.atlas_project_id
  cidr_block = var.gcp_networkcidr_block
  comment    = "CIDR block of the GPC VPCs"
}

# fetch information of gcp vpc
data "google_compute_network" "gcp_vpc_info" {
  name = var.vpc_network_name
  project = var.project_id
}

# Create the GCP peer
resource "google_compute_network_peering" "peering" {
  depends_on = [data.google_compute_network.gcp_vpc_info, mongodbatlas_network_peering.gcp-atlas]
  name         = var.peering_connection_name
  network      = data.google_compute_network.gcp_vpc_info.self_link
  peer_network = "https://www.googleapis.com/compute/v1/projects/${mongodbatlas_network_peering.gcp-atlas.atlas_gcp_project_id}/global/networks/${mongodbatlas_network_peering.gcp-atlas.atlas_vpc_name}"
}