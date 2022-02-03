variable "aws_region" {
  description = "aws region"
  type        = string
}

variable "vpc" {
  description = "All vpc info"
  type = object({
    name = string
    vpc_id   = string
  })
}

variable "atlas_public_key" {
  type = string
  description = "The public API key for MongoDB Atlas"
}

variable "atlas_private_key" {
  type = string
  description = "The private API key for MongoDB Atlas"
}

variable "atlas_region" {
  type = string
  description = "Atlas Region"
}

variable "atlas_vpc_cidr" {
  description = "Atlas CIDR"
  type = string
}

variable "atlas_project_id" {
  description = "MongoDB Atlas project id"
  type        = string
}

variable "default_tags" {
  description = "Default Tags for peering connections"
  type        = map(string)
}
