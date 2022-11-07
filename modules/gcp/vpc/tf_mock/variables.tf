variable "project_id" {
  type        = string
  description = "The ID of the project where this VPC will be created"
}

variable "region" {
  type        = string
  description = "Region in which to deploy the resources"
}

variable "network_name" {
  description = "The name of the network being created"
  type        = string
}


variable "private_service_access_name" {
  description = "The name of the private service access to be used"
  type        = string
}
