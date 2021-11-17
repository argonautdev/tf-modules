variable "default_tags" {
  description = "Default Tags for s3"
  type        = map(string)
}

variable "aws_region" {
  default     = "us-east-1"
  description = "Region"
}

variable "repositories" {
  type = list(object({
    name                 = string
    image_tag_mutability = string
    scan_on_push         = bool
    encryption_type      = string
    kms_key              = string
    policy               = string
    timeouts_delete      = string
    lifecycle_policy     = string
  }))
  default     = []
  description = "Configuration for repositories"
}

variable "cross_replication" {
  type = list(object({
    region = string
  }))
  default = []
  description = "All cross replication inputs"
}
