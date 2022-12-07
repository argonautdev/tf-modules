variable "project_id" {
  description = "The project ID to manage the Cloud SQL resources"
  type        = string
}

// required
variable "region" {
  description = "The region of the Cloud SQL resources"
  type        = string
  default     = "us-east4"
}

variable "name" {
  description = "The ID of the instance or a fully qualified identifier for the instance."
  type        = string
}

variable "vpc_network_name" {
  description = "The VPC Network name"
  type        = string
  default = ""
}

//fundamental unit of memcached instance.
variable "node_count" {
  description = "Number of nodes in the memcache instance."
  type        = number
  default     = 1
}

variable "cpu_count" {
  description = "Number of CPUs per node"
  type        = number
  default     = 1
}

variable "memory_size_mb" {
  description = "Memcache memory size in MiB. Defaulted to 1024"
  type        = number
  default     = 1024
}

variable "zones" {
  description = "Zones where memcache nodes should be provisioned. If not provided, all zones will be used."
  type        = list(string)
  default     = []
}

variable "labels" {
  description = "The resource labels to represent user provided metadata."
  type        = map(string)
  default     = {}
}

variable "default_labels" {
  type        = map(string)
  default     = {}
  description = "The key/value labels for the master instances."
}

variable "params" {
  description = "Parameters for the memcache process"
  type        = map(string)
  default     = {}
}