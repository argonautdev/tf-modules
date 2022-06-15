##Not Passing Zone Parameter to Module, If We Don't Pass zone, default locations are selected.
##Not adding gcp_filestore_csi_driver, gce_persistent_disk_csi_driver_config, We use helm to install these drivers, Addons doesn't provide all the features ( ex: snapshot )  
module "gke" {
    source  = "terraform-google-modules/kubernetes-engine/google"
    version = "21.1.0"
    project_id   = var.project_id
    name    = var.cluster_name
    description = var.description
    region  = var.region
    network = var.network_name
    subnetwork = var.cluster_node_subnet_name
    ip_range_pods = var.cluster_pods_subnet_name
    ip_range_services = var.cluster_service_subnet_name
    http_load_balancing = var.http_load_balancing
    kubernetes_version = var.kubernetes_version
    initial_node_count = var.initial_node_count ##How many instances should be launched in each zone
    cluster_resource_labels = var.cluster_resource_labels
    node_pools = var.node_pools
    remove_default_node_pool = var.remove_default_node_pool
    //kubernetes_version = var.kubernetes_version
    /*Node Pool taints, Labels, tags */
    node_pools_labels = var.node_pools_labels
    node_pools_taints = var.node_pools_taints
    node_pools_tags = var.node_pools_tags
    default_max_pods_per_node = var.default_max_pods_per_node
}    