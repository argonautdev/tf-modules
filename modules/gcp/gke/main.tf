##Not Passing Zone Parameter to Module, If We Don't Pass zone, default locations are selected.
##Not adding gcp_filestore_csi_driver, gce_persistent_disk_csi_driver_config, We use helm to install these drivers, Addons doesn't provide all the features ( ex: snapshot )  
##By Default the following Module Creats 

## These secondary subnets are mandatory if we would want to launch GKE cluster in VPC Native Cluster. 
## Ref: https://jayendrapatil.com/google-kubernetes-engine-networking/
resource "google_compute_subnetwork" "cluster_subnet" {
  name          = var.subnetwork_name
  ip_cidr_range = var.subnetwork_cidr
  region        = var.region
  project       = var.project_id
  network       = var.network_name
  private_ip_google_access = true
  secondary_ip_range = [
    {
        range_name    = var.pod_subnet_name
        ip_cidr_range = var.pod_subnet_cidr_block
    },
    {
        range_name    = var.service_subnet_name
        ip_cidr_range = var.service_subnet_cidr_block
    }
  ]
}

module "gke" {
  depends_on = [google_compute_subnetwork.cluster_subnet]
  source = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  # source  = local.gke_source
  version                  = "21.1.0"
  project_id               = var.project_id
  name                     = var.cluster_name
  description              = var.description
  region                   = var.region
  network                  = var.network_name
  subnetwork               = var.subnetwork_name
  ip_range_pods            = var.pod_subnet_name
  ip_range_services        = var.service_subnet_name
  master_ipv4_cidr_block   = var.master_ipv4_cidr_block
  http_load_balancing      = var.http_load_balancing
  filestore_csi_driver     = var.filestore_csi_driver
  kubernetes_version       = var.kubernetes_version
  initial_node_count       = var.initial_node_count ##How many instances should be launched in each zone
  cluster_resource_labels  = var.cluster_resource_labels
  node_pools               = var.node_pools
  remove_default_node_pool = var.remove_default_node_pool
  //kubernetes_version = var.kubernetes_version
  /*Node Pool taints, Labels, tags */
  node_pools_labels         = var.node_pools_labels
  node_pools_taints         = var.node_pools_taints
  node_pools_tags           = var.node_pools_tags
  default_max_pods_per_node = var.default_max_pods_per_node
  grant_registry_access     = var.grant_registry_access
  /*PrivateCluster Specifics*/
  enable_private_endpoint = var.enable_private_endpoint
  enable_private_nodes    = var.enable_private_nodes
  master_authorized_networks = var.master_authorized_networks
}


