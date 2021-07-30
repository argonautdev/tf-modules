variable "aws_region" {
  description = "aws region"
  type        = string
}

variable "name" {
  description = "Name of redis cluster"
  type        = string
}

variable "engine_version" {
  description = "Engine version"
  type        = string
}

variable "node_type" {
  description = "Type of Node"
  type        = string
}

variable "num_cache_nodes" {
  description = "Number of cache nodes"
  type        = number
}

variable "parameter_group_name" {
  description = "Parameter group"
  type        = string
}