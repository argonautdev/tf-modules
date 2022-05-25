variable "default_tags" {
  description = "Default Tags"
  type        = map(string)
}

variable "aws_region" {
  description = "aws region"
  type        = string
}

variable "comment" {
  description = "Any comments you want to include about the distribution."
  type        = string
  default     = "Cloudfront deployed by argonaut dev team"
}

variable "aliases" {
  description = "Extra CNAMEs (alternate domain names), if any, for this distribution."
  type        = list(string)
  default     = null
}

variable "default_root_object" {
  description = "The object that you want CloudFront to return (for example, index.html) when an end user requests the root URL."
  type        = string
  default     = null
}

variable "is_ipv6_enabled" {
  description = "Whether the IPv6 is enabled for the distribution."
  type        = bool
  default     = true
}

variable "price_class" {
  description = "The price class for this distribution. One of PriceClass_All, PriceClass_200, PriceClass_100"
  type        = string
  default     = "PriceClass_All"
}

variable "retain_on_delete" {
  description = "Disables the distribution instead of deleting it when destroying the resource through Terraform. If this is set, the distribution needs to be deleted manually afterwards."
  type        = bool
  default     = false
}

variable "wait_for_deployment" {
  description = "If enabled, the resource will wait for the distribution status to change from InProgress to Deployed. Setting this tofalse will skip the process."
  type        = bool
  default     = true
}

variable "custom_origin_dns_name" {
  description = "The DNS domain name of web site of your custom origin."
  type        = string
}

##To learn more about origin protocol policy
##https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/distribution-web-values-specify.html?icmpid=docs_cf_help_panel#DownloadDistValuesOriginProtocolPolicy
variable "origin_protocol_policy" {
  description = "Protocol that cloudfront to use when connecting to the origin. Supported values (http-only, https-only, or match-viewer)"
  type        = string
  default = "http-only"
}


##Cache Behavior Arguments###
variable "allowed_methods" {
  description = "Controls which HTTP methods CloudFront processes and forwards to your custom origin"
  type        = list(any)
  default = ["GET", "HEAD"]
}

variable "cached_methods" {
  description = "Controls whether CloudFront caches the response to requests using the specified HTTP methods"
  type        = list(any)
  default = ["GET", "HEAD"]
}


variable "logging_config" {
  description = "The logging configuration that controls how logs are written to your distribution (maximum one)."
  type        = any
  default     = {}
}