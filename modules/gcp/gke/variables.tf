variable "project_id" {
    type = string
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
    type = string
    description = "Region in which to deploy the resources"
}

variable "cluster_node_zones" {
  type = list(string)
  description = "The list of zones in which the cluster's nodes are located."
  default = []
}

variable "network_name" {
  description = "The VPC network to host the cluster in (required)"
  type = string
}

variable "cluster_node_subnet_name" {
  type        = string
  description = "The _name_ of subnetwork in which the cluster's instances are launched"
}

variable "cluster_pods_subnet_name" {
  type        = string
  description = "The _name_ of the secondary subnet to use for pods"
}

variable "cluster_service_subnet_name" {
  type        = string
  description = "The _name_ of the secondary subnet to use for services"
}

variable "http_load_balancing" {
  type        = bool
  description = "Enable httpload balancer addon"
  default     = true
}

variable "kubernetes_version" {
  type = string
  description = "The Kubernetes version of the masters."
  default = "latest"
}

variable "initial_node_count" {
  type        = number
  description = "The number of nodes to create in this cluster's default node pool."
  default     = 1
}

variable "cluster_resource_labels" {
  type        = map(string)
  description = "The GCE resource labels (a map of key/value pairs) to be applied to the cluster"
  default     = {}
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
  default = {
    applications = {
      "nodeType": "linux",
      "worload_type": "monitoring"
    }
  }
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