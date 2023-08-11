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

variable "regional" {
  type        = bool
  description = "Whether is a regional cluster (zonal cluster if set false. WARNING: changing this after cluster creation is destructive!)"
  default     = true
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
  type        = list(object({ 
     cidr_block = string, 
     display_name = string
  }))
  description = "List of master authorized networks. If none are provided, disallow external access (except the cluster node IPs, which GKE automatically whitelists)."
  default     = []
}

/* CIDR Block will be used by GKE and creats endpoint and peer with our network */
variable "master_ipv4_cidr_block" {
  type        = string
  description = "(Beta) The IP range in CIDR notation to use for the hosted master network"
  default     = "10.0.0.0/28"
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
  default     = true
}

## https://cloud.google.com/kubernetes-engine/versioning#specifying_cluster_version
variable "platform_version" {
  type        = string
  description = "The Kubernetes version of the masters."
}

variable "initial_node_count" {
  type        = number
  description = "The number of nodes to create in this cluster's default node pool."
  default     = 1
}

##Default labels
variable "default_labels" {
  type = map(string)
  description = "default labels for resources"
  default = {}
}

##User specific labels to be applied on resources along with defaults
variable "labels" {
  type        = map(string)
  description = "The GCE resource labels (a map of key/value pairs) to be applied to the cluster"
  default     = {}
}

variable "node_pools" {
  type = list(object({
      name = string,
      machine_type = string,
      disk_size_gb = number,
      disk_type = string,
      image_type = string,
      autoscaling = bool,
      min_count = optional(number), ##Pass value only if autoscaling is set to true
      max_count = optional(number), ##Pass value only if autoscaling is set to true
      auto_repair = optional(bool),
      auto_upgrade = bool,
      preemptible = optional(bool),
      spot = optional(bool),
      enable_gcfs = bool,##Set to true only if image streaming is required.
      accelerator_type = optional(string),
      accelerator_count = optional(number),
  }))
  description = "List of maps containing node pools"
  default = [
    {
      name = "default-node-pool",
      machine_type    = "e2-medium",
      disk_size_gb = 50,
      disk_type       = "pd-balanced"
      image_type      = "COS_CONTAINERD"
      autoscaling     = false
      auto_upgrade    = false,
      spot    = false,
      enable_gcfs     = false
    }
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
  default = {
    default-node-pool = {}
  }
}

variable "node_pools_taints" {
  type        = map(list(object({ 
      key = string, 
      value = string, 
      effect = string 
  })))
  description = "Map of lists containing node taints by node-pool name"
  default = {}
}

variable "node_pools_tags" {
  type        = map(list(string))
  description = "Map of lists containing node network tags by node-pool name"
  default = {}
}

variable "default_max_pods_per_node" {
  type        = number
  description = "The maximum number of pods to schedule per node"
  default     = 110
}

##By default this is false in public module, so override that by saying to true
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
