variable "aws_region" {
  description = "provider region"
  default     = "us-west-2"
}

variable "default_tags" {
  description = "Default Tags for Auto Scaling Group"
  type        = map(string)
}

variable "spot_tags" {
  description = "All the additional spot tags"
  type        = map(string)
}

variable "on_demand_tags" {
  description = "All the additional ondemand tags"
  type        = map(string)
}

variable "spot_labels" {
  description = "All the spot lables"
  description = "Default Tags for Auto Scaling Group"
  type        = map(string)
}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)
}

variable "cluster" {
  description = "All cluster info (singular)"
  type = object({
    name = string
  })
}

variable "vpc" {
  description = "All vpc info"
  type = object({
    name = string
    vpc_id = string
    private_subnets = list(string)
  })
}

variable "node_group" {
  description = "All node_group info (singular)"
  type = object({
    name = string 
    desired_capacity = number
    max_capacity = number
    min_capacity = number
    disk_size = number
    instance_type = string
    spot = bool
  })
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
}

variable "env" {
  description = "environment name"
} 