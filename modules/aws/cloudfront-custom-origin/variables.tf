variable "default_tags" {
  description = "Default Tags"
  type        = map(string)
}

variable "aws_region" {
  description = "aws region"
  type        = string
}

variable "app_name" {
  description = "argo app name"
  type        = string
}

variable "description" {
  description = "Any comments you want to include about the distribution."
  type        = string
  default     = "Cloudfront deployed by argonaut dev team"
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
  default     = ""
}

##To learn more about origin protocol policy
##https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/distribution-web-values-specify.html?icmpid=docs_cf_help_panel#DownloadDistValuesOriginProtocolPolicy
variable "origin_protocol_policy" {
  description = "Protocol that cloudfront to use when connecting to the origin. Supported values (http-only, https-only, or match-viewer)"
  type        = string
  default = "match-viewer"
}

##Cache Behavior Arguments###
##Regarding Methods Ref: https://jayendrapatil.com/aws-cloudfront/#:~:text=Allowed%20HTTP%20methods,and%20to%20get%20object%20headers.&text=CloudFront%20only%20caches%20responses%20to,and%2C%20optionally%2C%20OPTIONS%20requests.
variable "allowed_methods" {
  description = "Controls which HTTP methods CloudFront processes and forwards to your custom origin, for ex: 'DELETE', 'GET', 'HEAD', 'OPTIONS', 'PATCH', 'POST', 'PUT'"
  type        = list(any)
  default = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "OPTIONS", "PATCH", "DELETE"]
}

variable "cached_methods" {
  description = "Controls whether CloudFront caches the response to requests using the specified HTTP methods"
  type        = list(any)
  default = ["GET", "HEAD"]
}

# This is id for SecurityHeadersPolicy copied from https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-response-headers-policies.html
variable "response_headers_policy_id" {
  description = "Policy ID for managed response headers policies that you can attach to cache behaviors in your CloudFront distributions."
  type        = string
  default = "60669652-455b-4ae9-85a4-c4c02393f86c"
}

# https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-cache-policies.html
variable "cache_policy_id" {
  description = "Policy ID for cache behaviors in your CloudFront distributions."
  type        = string
  default = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
}

# https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-origin-request-policies.html
variable "origin_request_policy_id" {
  description = "Policy ID for origin request behaviors in your CloudFront distributions."
  type        = string
  default = "216adef6-5c7f-47e4-b989-5492eafa07d3"
}


/* CF logging */
variable "logging" {
  description = "Set to true to enable cloudfront standard/accesslogging"
  type        = bool
  default     = true
}

/* CF Custom Domain */
variable "domain_name" {
  type = string
  description = "Name of the hostedzone/domainname which is present in route53"
  default = ""
}

variable "subdomain" {
  type = string
  description = "Name of subdomain"
  default = ""
}

variable "aliases" {
  description = "Extra CNAMEs (alternate domain names), if any, for this distribution."
  type        = list(string)
  default     = []
}

# DNS records
variable "create_dns_records" {
  description = "Set to true to create DNS records corresponding to the domains, subdomains, and aliases"
  type        = bool
  default     = false
}
