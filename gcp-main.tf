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

module "mysql-private" {
  source            = "./modules/gcp/mySQL"
  project_id        = "playground-351903"
  region            = "us-east4"
  name              = "argonaut-dev-private-db-3453"
  database_version  = "MYSQL_8_0"
  db_connectivity_type = "private"
  vpc_network_name = "dev-microservices-new-vpc"
  address          = "10.240.0.0"
  db_compute_instance_size = "db-n1-standard-2" ##2 vcpu, 8GB ram
  user_labels = {
    "env" : "dev",
    "type" : "mysql-private-db"
  }
  zone                       = "us-east4-a"
  activation_policy          = "ALWAYS"
  availability_type          = "REGIONAL"
  disk_autoresize            = true
  disk_autoresize_limit      = 100
  disk_size                  = 20
  disk_type                  = "PD_SSD"
  maintenance_window_day     = 6 ##Saturday
  maintenance_window_hour    = 23 ##11:00 AM ( to be in the range (0 - 23))
  /* Backup */
  binary_log_enabled        = true
  enabled                   = true
  location                  = "us" ##trying with multiregion.
  retained_backups          = 14
  transaction_log_retention_days = 7
  retention_unit = "COUNT"
  ipv4_enabled = false
  db_name = "tempdb"
  user_name = "argonaut"
  user_password = "argonautadmin123#"
  deletion_protection = false
  ##Max limit to 10
  ## To Create replicas, Backup and binary logging should be enabled. 
  # read_replicas = [
  # {
  #   name = "primary-replica"
  #   tier = "db-n1-standard-4"
  #   #The automatic storage increase setting of a primary instance automatically applies to any read replicas of that instance. 
  #   #The automatic storage increase setting cannot be independently set for read replicas.
  #   disk_type = "PD_SSD"
  #   disk_autoresize = false
  #   disk_autoresize_limit = 500
  #   database_flags = []
  #   disk_size = 200
  #   zone = "us-east4-b"
  #   user_labels = {
  #     "env" : "dev",
  #     "type" : "mysql-private-db-primary-replica"
  #   },
  #   encryption_key_name = null
  # }]
}

module "mysql-public" {
  source            = "./modules/gcp/mySQL"
  project_id        = "playground-351903"
  region            = "us-east4"
  name              = "argonaut-dev-public-db-1233"
  database_version  = "MYSQL_8_0"
  db_connectivity_type = "public"
  ##Below is one mandatory if it's public
  authorized_networks  = [{ name = "Allowing All Ip", value = "0.0.0.0/0" }]
  vpc_network_name = "dev-microservices-new-vpc"
  db_compute_instance_size = "db-n1-standard-2" ##2 vcpu, 8GB ram
  user_labels = {
    "env" : "dev",
    "type" : "mysql-public-db"
  }
  zone                       = "us-east4-a"
  activation_policy          = "ALWAYS"
  availability_type          = "ZONAL"
  disk_autoresize            = true
  disk_autoresize_limit      = 100
  disk_size                  = 20
  disk_type                  = "PD_SSD"
  maintenance_window_day     = 6 ##Saturday
  maintenance_window_hour    = 23 ##11:00 AM ( to be in the range (0 - 23))
  /* Backup */
  binary_log_enabled        = true
  enabled                   = true
  location                  = "us" ##trying with multiregion.
  retained_backups          = 14
  transaction_log_retention_days = 7
  retention_unit = "COUNT"
  ipv4_enabled = false
  db_name = "tempdb"
  user_name = "argonaut"
  user_password = "argonautadmin123#"
  deletion_protection = false
}

module "postgresql" {
  source            = "./modules/gcp/postgreSQL"
  project_id        = "playground-351903"
  region            = "us-east4"
  name              = "argonaut-dev-postgrsql-private-db-34533"
  database_version  = "POSTGRES_13"
  db_connectivity_type = "private"
  vpc_network_name = "dev-microservices-new-vpc"
  address          = "10.240.0.0"
  ##Postgres only supports custom and shared instancetypes.
  db_compute_instance_size = "db-custom-2-7680" ##2 vcpu, 8GB ram
  user_labels = {
    "env" : "dev",
    "type" : "postgrsql-private-db"
  }
  zone                       = "us-east4-a"
  activation_policy          = "ALWAYS"
  availability_type          = "ZONAL"
  disk_autoresize            = true
  disk_autoresize_limit      = 100
  disk_size                  = 20
  disk_type                  = "PD_SSD"
  maintenance_window_day     = 6 ##Saturday
  maintenance_window_hour    = 23 ##11:00 AM ( to be in the range (0 - 23))
  /* Backup */
  point_in_time_recovery_enabled = true
  enabled                   = true
  location                  = "us" ##trying with multiregion.
  retained_backups          = 14
  transaction_log_retention_days = 7
  retention_unit = "COUNT"
  ipv4_enabled = false
  db_name = "tempdb"
  user_name = "argonaut"
  user_password = "argonautadmin123#"
  deletion_protection = false
  ##Max limit to 10
  ## To Create replicas, Backup and binary logging should be enabled. 
  read_replicas = [
    {
      name = "0"
      tier = "db-custom-2-7680"
      #The automatic storage increase setting of a primary instance automatically applies to any read replicas of that instance. 
      #The automatic storage increase setting cannot be independently set for read replicas.
      disk_type = "PD_SSD"
      disk_autoresize = false
      disk_autoresize_limit = 500
      database_flags = []
      disk_size = 200
      zone = "us-east4-b"
      user_labels = {
        "env" : "dev",
        "type" : "postgresql-private-db-primary-replica"
      },
      encryption_key_name = null
    }
  ]
}


module "gcs_bucket" {
  source            = "./modules/gcp/gcs"
  project_id        = "playground-351903"
  region            = "us-east4"
  names             = ["demo-bucket-123"]
  location          = "US-EAST4"
  storage_class = "NEARLINE"
  force_destroy = {
    demo-bucket-123 = true
  }
  versioning = {
    demo-bucket-123 = true
  }
  labels = {
      "env" : "dev",
      "type" : "logstoragebucket"
  }  
  lifecycle_rules = [
  {
    action = {
      "type" :  "SetStorageClass",
      "storage_class": "COLDLINE"
    }  
    condition = {
      "age": 30
      "with_state": "LIVE"
      
    }
  },
  {
    action = {
      "type" :  "SetStorageClass",
      "storage_class": "ARCHIVE"
    }  
    condition = {
      "age": 90
      "with_state": "LIVE"
      "matches_storage_class": "COLDLINE"
    }
  },
  {
    action = {
      "type" :  "Delete"
    }  
    condition = {
      # {"age": 365, "isLive": true, "matchesStorageClass": ["ARCHIVE"]}
      "age": 365,
      "with_state": "LIVE", ##Current Versions of Objects
      "matches_storage_class": "ARCHIVE"
    }
  }]
  ##Permissions testing
  set_creator_roles = true
  bucket_creators = {
    demo-bucket-123 = "serviceAccount:storage-service-permission-tes@playground-351903.iam.gserviceaccount.com"
  }
  set_viewer_roles = true
  bucket_viewers = {
    demo-bucket-123 = "serviceAccount:storage-service-permission-tes@playground-351903.iam.gserviceaccount.com"
  }
}

// Master
output "instance_name" {
  value       = module.mysql-public.instance_name
  description = "The instance name for the master instance"
}

output "instance_ip_address" {
  value       = module.mysql-public.instance_ip_address
  description = "The IPv4 address assigned for the master instance"
}

output "private_address" {
  value       = module.mysql-public.private_address
  description = "The private IP address assigned for the master instance"
}

output "instance_first_ip_address" {
  value       = module.mysql-public.instance_first_ip_address
  description = "The first IPv4 address of the addresses assigned for the master instance."
}

output "instance_connection_name" {
  value       = module.mysql-public.instance_connection_name
  description = "The connection name of the master instance to be used in connection strings"
}

output "instance_self_link" {
  value       = module.mysql-public.instance_self_link
  description = "The URI of the master instance"
}

output "instance_server_ca_cert" {
  value       = module.mysql-public.instance_server_ca_cert
  description = "The CA certificate information used to connect to the SQL instance via SSL"
}

output "instance_service_account_email_address" {
  value       = module.mysql-public.instance_service_account_email_address
  description = "The service account email address assigned to the master instance"
}

// Replicas
output "replicas_instance_first_ip_addresses" {
  value       = module.mysql-public.replicas_instance_first_ip_addresses
  description = "The first IPv4 addresses of the addresses assigned for the replica instances"
}

output "replicas_instance_connection_names" {
  value       = module.mysql-public.replicas_instance_connection_names
  description = "The connection names of the replica instances to be used in connection strings"
}

output "replicas_instance_self_links" {
  value       = module.mysql-public.replicas_instance_self_links
  description = "The URIs of the replica instances"
}

output "replicas_instance_server_ca_certs" {
  value       = module.mysql-public.replicas_instance_server_ca_certs
  description = "The CA certificates information used to connect to the replica instances via SSL"
}

output "replicas_instance_service_account_email_addresses" {
  value       = module.mysql-public.replicas_instance_service_account_email_addresses
  description = "The service account email addresses assigned to the replica instances"
}

output "read_replica_instance_names" {
  value       = module.mysql-public.read_replica_instance_names
  description = "The instance names for the read replica instances"
}

output "public_ip_address" {
  description = "The first public (PRIMARY) IPv4 address assigned for the master instance"
  value       = module.mysql-public.public_ip_address
}

output "private_ip_address" {
  description = "The first private (PRIVATE) IPv4 address assigned for the master instance"
  value       = module.mysql-public.private_ip_address
}