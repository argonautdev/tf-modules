variable "region" {}

# AWS Elasticsearch
variable "es_domain_name" {}
variable "es_version" {}

variable "vpc" {
  description = "All vpc info"
  type = object({
    name = string
    id   = string
    subnets = list(string)
    default_security_group_id = string
  })
}

variable "tags" {
  description = "Default Tags"
  type = map(string)
}