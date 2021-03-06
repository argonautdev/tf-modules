variable "aws_region" {
  default = "us-west-2"
}

variable "default_tags" {
  description = "Default Tags for Auto Scaling Group"
  type        = map(string)
}

variable "spot_tags" {
  description = "Spot tags"
  type        = map(string)
}

variable "on_demand_tags" {
  description = "On demand tags"
  type        = map(string)
}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)
}

variable "cluster" {
  description = "All cluster info (singular)"
  type = object({
    name    = string
    version = string
  })
  default = {
    name    = "argonaut"
    version = "1.21"
  }
}

variable "vpc" {
  description = "All vpc info"
  type = object({
    name    = string
    id      = string
    subnets = list(string)
  })
}

variable "node_group" {
  description = "All node_group info (singular)"
  type = object({
    name_prefix      = string
    desired_capacity = number
    max_capacity     = number
    min_capacity     = number
    disk_size        = number
    instance_type    = string
    spot             = bool
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

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
}

variable "env" {
  description = "environment name"
}

variable "k8s_service_account_name" {
  type = string
}

variable "ami_type" {
  default = "AL2_x86_64"
  type    = string
}

variable "k8s_service_account_namespace" {
  default = "tools"
  type    = string
}