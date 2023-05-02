variable "project_id" {
  description = "The project ID of GCP"
  type        = string
}

// required
variable "region" {
  description = "The region of the Cloud SQL resources"
  type        = string
  default     = "us-east4"
}

variable "vpc_network_name" {
  description = "The VPC Network name"
  type        = string
  default = ""
}

variable "peering_connection_name" {
  description = "Peering connection name"
  type        = string
  default = "gcp-mongoatlas-peer"
}

##Our intent of creating this module is enable secure private access from GCP to MongDB Atlas cluster. The module is generic. 
##In our case, The following variable should be the value of GKE Cluster subnetwork. Bcoz at the end of the day users run their workloads on cluster only.
variable "gcp_networkcidr_block" {
  description = "GCP vpc_cidr block"
  type        = string
  default     = "10.0.0.0/8"
}

variable "atlas_public_key" {
  type = string
  description = "The public API key for MongoDB Atlas"
}

variable "atlas_private_key" {
  type = string
  description = "The private API key for MongoDB Atlas"
}

##if we pass "atlas_cidr_block" smaller than "/18" then we also need to pass "atlas_regions" regions.
## For GCP networks we are using "10" series. To avoid overlapping atlas_vpc_cidr uses 192.168.0.0/16.      
variable "atlas_vpc_cidr" {
  description = "Atlas CIDR"
  type = string
  default = "192.168.0.0/16"
}

variable "atlas_project_id" {
  description = "MongoDB Atlas project id"
  type        = string
}
