module "vpc" {
  source       = "./modules/gcp/vpc"
  project_id   = "playground-351903"
  region       = "us-east4"
  network_name = "dev-microservices-new-vpc"
  description  = "custom vpc for kubernetes engine workloads"
  subnets = [
    {
      subnet_name           = "dev-microservices-new-public-subnet"
      subnet_ip             = "10.10.0.0/16"
      subnet_region         = "us-east4"
      subnet_private_access = false ##Setting to false as it should be act as public subnet
      subnet_flow_logs      = "false"
      description           = "Public subnets for running application frontend servers"
    },
    {
      subnet_name           = "dev-microservices-new-private-subnets"
      subnet_ip             = "10.20.0.0/16"
      subnet_region         = "us-east4"
      subnet_private_access = true
      subnet_flow_logs      = "false"
      description           = "Private subnets for running application backend servers"
    },
    {
      subnet_name           = "dev-microservices-new-database-subnets"
      subnet_ip             = "10.30.0.0/16"
      subnet_region         = "us-east4"
      subnet_private_access = true
      subnet_flow_logs      = "false"
      description           = "Subnets for running database. for instance, Cloud SQL"
    }
  ]

  ##CloudNat & Router Info
  router_description = "Router used by cloud nat"
  router_name        = "dev-microservices-new-vpc-router"
  nats = [
    {
      "name" : "dev-microservices-new-vpc-nat",
      "nat_ip_allocate_option" : "AUTO_ONLY",
      "source_subnetwork_ip_ranges_to_nat" : "ALL_SUBNETWORKS_ALL_IP_RANGES"
  }]
}

##Public and Private GKE Cluster
module "kubernetes_engine" {
  source                      = "./modules/gcp/gke"
  project_id                  = "playground-351903"
  region                      = "us-east4"
  network_name                = "dev-microservices-new-vpc"
  cluster_name                = "dev-new-cluster"
  description                 = "Public and Private endpoint cluster for running containerized application that makes up the application"
  cluster_node_zones          = ["us-east4-a", "us-east4-b"]
  /*Networking Details*/
  subnetwork_name             = "dev-cluster-subnet"
  subnetwork_cidr             = "10.40.0.0/16"
  pod_subnet_name             = "dev-cluster-pod-subnet"
  pod_subnet_cidr_block       = "10.41.0.0/16"
  service_subnet_name         = "dev-cluster-services-subnet"
  service_subnet_cidr_block   = "10.42.0.0/16"
  ## The IP range in CIDR notation used for the hosted master network
  ## If you ignore the parameter by default it will reserve "10.0.0.0/28" 
  ## If we use same vpc next time for creating another cluster, it fails because 
  # https://docs.google.com/document/d/1WF5bJobHc1C_g6Eb09rYQNzUw497YTpTEHpxub_Mwws/edit ---> Look the image here in google doc
  master_ipv4_cidr_block      = "10.0.0.0/28" 
  /*Addons*/
  http_load_balancing         = false
  filestore_csi_driver        = true
  enable_vertical_pod_autoscaling = false
  horizontal_pod_autoscaling = true
  /* labels */
  /* Labels for organizing resources and can be used in finding resource billing */
  cluster_resource_labels    = {
      env      = "dev"
      type     = "public-gke-cluster"
  }
  initial_node_count          = 1
  node_pools = [
    {
      name            = "applications"
      machine_type    = "e2-medium"
      node_locations  = "us-east4-a,us-east4-b,us-east4-c"
      autoscaling     = true
      min_count       = 1
      max_count       = 3
      local_ssd_count = 0
      disk_size_gb    = 100
      disk_type       = "pd-balanced"
      image_type      = "COS_CONTAINERD"
      enable_gcfs     = false
      auto_repair     = true
      auto_upgrade    = true
      preemptible     = true
    },
    # {
    #   name            = "monitoring"
    #   machine_type    = "e2-medium"
    #   node_locations  = "us-east4-a,us-east4-b,us-east4-c"
    #   autoscaling     = true
    #   min_count       = 1
    #   max_count       = 5
    #   local_ssd_count = 0
    #   disk_size_gb    = 100
    #   disk_type       = "pd-balanced"
    #   image_type      = "COS_CONTAINERD"
    #   enable_gcfs     = false
    #   auto_repair     = true
    #   auto_upgrade    = true
    #   preemptible     = false
    # }
  ]
  node_pools_labels = {
    monitoring = {
      workload_type = "monitoring"
    }
  }
  node_pools_taints = {
    monitoring = [{
      key    = "workload_type"
      value  = "monitoring"
      effect = "NO_SCHEDULE"
    }, ]
  }
  /*PrivateCluster Specifics*/
  enable_private_endpoint = false ##Making Master API endpoint public
  enable_private_nodes    = true
  /* Note: When you Pass "enable_private_endpoint" to true you must pass the value for below variable */
  #format  = list(object({ cidr_block = string, display_name = string }))
  master_authorized_networks = []
  
}

##Private GKE Cluster
module "kubernetes_private_engine_cluster" {
  source                      = "./modules/gcp/gke"
  project_id                  = "playground-351903"
  region                      = "us-east4"
  network_name                = "dev-microservices-new-vpc"
  cluster_name                = "dev-private-cluster"
  description                 = "Private endpoint cluster for running containerized application that makes up the application"
  cluster_node_zones          = ["us-east4-a", "us-east4-b"]
  /*Networking Details*/
  subnetwork_name             = "dev-private-cluster-subnet"
  subnetwork_cidr             = "10.50.0.0/16"
  pod_subnet_name             = "dev-private-cluster-pod-subnet"
  pod_subnet_cidr_block       = "10.51.0.0/16"
  service_subnet_name         = "dev-private-cluster-services-subnet"
  service_subnet_cidr_block   = "10.52.0.0/16"
  ## The IP range in CIDR notation used for the hosted master network
  ## If you ignore the parameter by default it will reserve "10.0.0.0/28" 
  ## If we use same vpc next time for creating another cluster, it fails because 
  # https://docs.google.com/document/d/1WF5bJobHc1C_g6Eb09rYQNzUw497YTpTEHpxub_Mwws/edit ---> Look the image here in google doc
  master_ipv4_cidr_block      = "10.1.0.0/28" 
  /*addons*/
  initial_node_count          = 1
  node_pools = [
    {
      name            = "applications"
      machine_type    = "e2-medium"
      node_locations  = "us-east4-a,us-east4-b,us-east4-c"
      autoscaling     = true
      min_count       = 1
      max_count       = 3
      local_ssd_count = 0
      disk_size_gb    = 100
      disk_type       = "pd-balanced"
      image_type      = "COS_CONTAINERD"
      enable_gcfs     = false
      auto_repair     = true
      auto_upgrade    = true
      preemptible     = true
    },
    # {
    #   name            = "monitoring"
    #   machine_type    = "e2-medium"
    #   node_locations  = "us-east4-a,us-east4-b,us-east4-c"
    #   autoscaling     = true
    #   min_count       = 1
    #   max_count       = 5
    #   local_ssd_count = 0
    #   disk_size_gb    = 100
    #   disk_type       = "pd-balanced"
    #   image_type      = "COS_CONTAINERD"
    #   enable_gcfs     = false
    #   auto_repair     = true
    #   auto_upgrade    = true
    #   preemptible     = false
    # }
  ]
  node_pools_labels = {
    monitoring = {
      workload_type = "monitoring"
    }
  }
  node_pools_taints = {
    monitoring = [{
      key    = "workload_type"
      value  = "monitoring"
      effect = "NO_SCHEDULE"
    }, ]
  }
  cluster_resource_labels    = {
      env      = "dev"
      type     = "private-gke-cluster"
  }
  /*PrivateCluster Specifics*/
  enable_private_endpoint = true
  enable_private_nodes    = true
  /* Note: When you Pass "enable_private_endpoint" to true you must pass the value for below variable */
  #format  = list(object({ cidr_block = string, display_name = string }))
  master_authorized_networks = [
    { cidr_block = "10.0.0.0/8", display_name = "Allowing from public subnets" }
  ]
}

module "bastion_host" {
  source            = "./modules/gcp/bastion"
  project_id        = "playground-351903"
  region            = "us-east4"
  image_family      = "ubuntu-1804-lts"
  image_project     = "ubuntu-os-cloud"
  bastion_host_name = "eks-cluster-bastion"
  tags              = ["eks-devcluster-bastion"]
  labels = {
    "env" : "dev",
    "type" : "bastion"
  }
  machine_type               = "e2-medium"
  disk_size_gb               = 20
  disk_type                  = "pd-balanced"
  network                    = module.vpc.network_self_link
  subnet                     = "https://www.googleapis.com/compute/v1/projects/playground-351903/regions/us-east4/subnetworks/dev-microservices-new-public-subnet"
  members                    = ["user:prashant@argonaut.dev", "user:surya@argonaut.dev"]
  fw_name_allow_ssh_from_iap = "allow-ssh-rule-from-iap" ##
  service_account_name       = "eks-devcluster-bastion"
  external_ip                = false
}