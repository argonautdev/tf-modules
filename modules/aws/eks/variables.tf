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

  # default = [
  #   "777777777777",
  #   "888888888888",
  # ]
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
    id   = string
    subnets = list(string)
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

# variable "node_group_tags" {
#   description = "All the node group tags apart from the default ones for all the resources"
#   type = map(string)
# }

# variable "node_group_labels" {
#   description = "All the node group labels"
#   type = map(string)
# }

# variable "map_roles" {
#   description = "Additional IAM roles to add to the aws-auth configmap."
#   type = list(object({
#     rolearn  = string
#     username = string
#     groups   = list(string)
#   }))

#   # default = [
#   #   {
#   #     rolearn  = "arn:aws:iam::66666666666:role/role1"
#   #     username = "role1"
#   #     groups   = ["system:masters"]
#   #   },
#   # ]
# }

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  # default = [
  #   {
  #     userarn  = "arn:aws:iam::66666666666:user/user1"
  #     username = "user1"
  #     groups   = ["system:masters"]
  #   },
  #   {
  #     userarn  = "arn:aws:iam::66666666666:user/user2"
  #     username = "user2"
  #     groups   = ["system:masters"]
  #   },
  # ]
}

variable "env" {
  description = "environment name"
}

variable "k8s_service_account_name" {
  type = string
}