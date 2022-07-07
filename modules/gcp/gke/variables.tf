variable "project_id" {
  type        = string
  description = "The ID of the project where this VPC will be created"
}

variable "cluster_name" {
  type        = string
  description = "The name of the cluster (required)"
}

variable "description" {
  type        = string
  description = "The description of the cluster"
  default     = ""
}

variable "region" {
  type        = string
  description = "Region in which to deploy the resources"
}

variable "cluster_node_zones" {
  type        = list(string)
  description = "The list of zones in which the cluster's nodes are located."
  default     = []
}

variable "network_name" {
  description = "The VPC network to host the cluster in (required)"
  type        = string
}

variable "subnetwork_name" {
  description = "The _name_ of subnetwork in which the cluster's instances are launched"
  type        = string
}

variable "pod_subnet_name" {
  type        = string
  description = "The _name_ of the secondary subnet to use for pods"
}

variable "service_subnet_name" {
  type        = string
  description = "The _name_ of the secondary subnet to use for services"
}

variable "subnetwork_cidr" {
  description = "Cidr of the subnetwork"
  type        = string
}

variable "pod_subnet_cidr_block" {
  type        = string
  description = "Pod subnetwork cidr block"
}

variable "service_subnet_cidr_block" {
  type        = string
  description = "Services subnetwork cidr block"
}

##The variable value is important if you would want to create a private cluster
###################
# Variables for Private Cluster
####################
variable "enable_private_endpoint" {
  type        = bool
  description = "Kubernetes cluster endpoint get private ip if you pass it as true"
  default     = false
}

variable "enable_private_nodes" {
  type        = bool
  description = "Nodes inside the nodepool get's privateip only when we pass is as true. Since we are using private subnets we want all of our nodes to have priavate IP"
  default     = false
}

/* Note: When you Pass "enable_private_endpoint" to true you must pass the value for below variable */
variable "master_authorized_networks" {
  type        = list(object({ cidr_block = string, display_name = string }))
  description = "List of master authorized networks. If none are provided, disallow external access (except the cluster node IPs, which GKE automatically whitelists)."
  default     = []
}

/* CIDR Block will be used by GKE and creats endpoint and peer with our network */
variable "master_ipv4_cidr_block" {
  type        = string
  description = "(Beta) The IP range in CIDR notation to use for the hosted master network"
  default     = "10.0.0.0/28"
}


/* Lables */

variable "cluster_resource_labels" {
  type        = map(string)
  description = "The GCE resource labels (a map of key/value pairs) to be applied to the cluster"
  default     = {}
}


/* Addons */
variable "http_load_balancing" {
  type        = bool
  description = "Enable httpload balancer addon"
  default     = false
}

variable "filestore_csi_driver" {
  type        = bool
  description = "The status of the Filestore CSI driver addon, which allows the usage of filestore instance as volumes"
  default     = true
}

variable "enable_vertical_pod_autoscaling" {
  type        = bool
  description = "Vertical Pod Autoscaling automatically adjusts the resources of pods controlled by it"
  default     = false
}

variable "horizontal_pod_autoscaling" {
  type        = bool
  description = "Enable horizontal pod autoscaling addon"
  default     = false
}

variable "config_connector" {
  type        = bool
  description = "(Beta) Whether ConfigConnector is enabled for this cluster."
  default     = false
}

variable "gce_pd_csi_driver" {
  type        = bool
  description = "(Beta) Whether this cluster should enable the Google Compute Engine Persistent Disk Container Storage Interface (CSI) Driver."
  default     = true
}

variable "monitoring_enable_managed_prometheus" {
  type        = bool
  description = "(Beta) Configuration for Managed Service for Prometheus. Whether or not the managed collection is enabled."
  default     = false
}

variable "istio" {
  description = "(Beta) Enable Istio addon"
  default     = false
}

variable "istio_auth" {
  type        = string
  description = "(Beta) The authentication type between services in Istio."
  default     = "AUTH_MUTUAL_TLS"
}

variable "kalm_config" {
  type        = bool
  description = "(Beta) Whether KALM is enabled for this cluster."
  default     = false
}

variable "enable_l4_ilb_subsetting" {
  type        = bool
  description = "Enable L4 ILB Subsetting on the cluster"
  default     = false
}

/* logging and monitoring */
/* GKE Bydefaults enables both */
/* Config connector requires Monitoring and Workload Identity Pool should be enabled */
/* About Logging and Monitoring ---> https://cloud.google.com/stackdriver/docs/solutions/gke/installing */
variable "logging_enabled_components" {
  type        = list(string)
  description = "List of services to monitor: SYSTEM_COMPONENTS, WORKLOADS. Empty list is default GKE configuration."
  default     = ["SYSTEM_COMPONENTS", "WORKLOADS"]
}

variable "monitoring_enabled_components" {
  type        = list(string)
  description = "List of services to monitor: SYSTEM_COMPONENTS, WORKLOADS ( Deprected ) (provider version >= 3.89.0). Empty list is default GKE configuration."
  default     = ["SYSTEM_COMPONENTS"]
}


variable "kubernetes_version" {
  type        = string
  description = "The Kubernetes version of the masters."
  default     = "latest"
}

variable "initial_node_count" {
  type        = number
  description = "The number of nodes to create in this cluster's default node pool."
  default     = 1
}

variable "node_pools" {
  type        = list(map(string))
  description = "List of maps containing node pools"

  default = [
    {
      name = "default-node-pool"
    },
  ]
}

variable "remove_default_node_pool" {
  type        = bool
  description = "Remove default node pool while setting up the cluster"
  default     = true
}

variable "node_pools_labels" {
  type        = map(map(string))
  description = "Map of maps containing node labels by node-pool name"

  # Default is being set in variables_defaults.tf
  default = {}
}

variable "node_pools_taints" {
  type        = map(list(object({ key = string, value = string, effect = string })))
  description = "Map of lists containing node taints by node-pool name"

  # Default is being set in variables_defaults.tf
  default = {}
}

variable "node_pools_tags" {
  type        = map(list(string))
  description = "Map of lists containing node network tags by node-pool name"

  # Default is being set in variables_defaults.tf
  default = {}
}

variable "default_max_pods_per_node" {
  type        = number
  description = "The maximum number of pods to schedule per node"
  default     = 110
}

##By default this false in public module, so override that by saying to true
variable "grant_registry_access" {
  type        = bool
  description = "Grants created cluster-specific service account storage.objectViewer and artifactregistry.reader roles."
  default     = true
}

variable "registry_project_ids" {
  type        = list(string)
  description = "Projects holding Google Container Registries. If empty, we use the cluster project. If a service account is created and the `grant_registry_access` variable is set to `true`, the `storage.objectViewer` and `artifactregsitry.reader` roles are assigned on these projects."
  default     = []
}

