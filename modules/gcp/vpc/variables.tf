variable "project_id" {
    type = string
    description = "The ID of the project where this VPC will be created"
}

variable "region" {
    type = string
    description = "Region in which to deploy the resources"
}

variable "network_name" {
  description = "The name of the network being created"
}

variable "subnets" {
  type        = list(map(string))
  default     = []
  description = "The list of subnets being created"
}

variable "secondary_ranges" {
  type = map(list(object({ range_name = string, ip_cidr_range = string })))
  description = "Map of secondaryrange in the cluster's subnetwork"
  default = {}
}

variable "description" {
  type        = string
  description = "An optional description of this resource. The resource must be recreated when modify this field."
  default     = ""
}