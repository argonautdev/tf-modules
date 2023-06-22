
variable "default_tags" {
  description = "Default Tags"
  type        = map(string)
}

variable "name" {
  description = "Name of redis cluster"
  type        = string
}

variable "parameter_group_name" {
  description = "Parameter group"
  default     = "default.redis6.x"
  type        = string
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

// variable "availability_zones" {
//   type        = list(string)
//   description = "Availability zone IDs"
// }

variable "cluster_size" {
  type        = number
  default    = 1
  description = "Number of nodes in cluster"
}

variable "instance_type" {
  type        = string
  description = "Elastic cache instance type"
}

variable "family" {
  type        = string
  default = "redis7"
  description = "Redis family"
}

variable "engine_version" {
  type        = string
  default = "7.0"
  description = "Redis engine version"
}

variable "at_rest_encryption_enabled" {
  type        = bool
  default = true
  description = "Enable encryption at rest"
}

variable "transit_encryption_enabled" {
  type        = bool
  description = "Enable TLS"
}

// variable "zone_id" {
//   type        = string
//   description = "Route53 DNS Zone ID"
// }

variable "cloudwatch_metric_alarms_enabled" {
  type        = bool
  default = true
  description = "Boolean flag to enable/disable CloudWatch metrics alarms"
}


variable "vpc" {
  description = "All vpc info"
  type = object({
    name = string
    vpc_id   = string
    public_subnets = list(string)
    private_subnets = list(string)
    database_subnets = list(string)
    default_security_group_id = string
    vpc_cidr_block = string
  })
}

variable "parameter" {
  type = list(object({
    name  = string
    value = string
  }))
  default     = []
  description = "A list of Redis parameters to apply. Note that parameters may differ from one Redis family to another"
}