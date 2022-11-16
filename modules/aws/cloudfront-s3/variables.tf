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

/* S3 Origin Parameters */

variable "create_origin_access_identity" {
  description = "Controls if CloudFront origin access identity should be created"
  type        = bool
  default     = true
}

variable "description" {
  description = "Any comments you want to include about the distribution."
  type        = string
  default     = "Cloudfront deployed by argonaut dev team"
}

/* CF Origin Bucket */
variable "cf_origin_create_bucket" {
  description = "Whether or not create cf origin bucket. If say 'true' bucket would be created with the name what ever you give in 'cf_origin_bucket_name'"
  type        = bool
  default     = true
}

variable "cf_origin_bucket_name" {
  description = "Name for cf origin bucket to create or Pass an existing bucket name when 'cf_origin_create_bucket' is set to false"
  type        = string
  default     = ""
}

variable "attach_policy" {
  description = "If your existing bucket has bucket policy and you want to append cf policy to s3 bucket say 'true' else 'false'"
  type        = bool
  default     = false
}

variable "block_public_acls" {
  description = "Whether Amazon S3 should block public ACLs for this bucket."
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Whether Amazon S3 should block public bucket policies for this bucket."
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Whether Amazon S3 should ignore public ACLs for this bucket."
  type        = bool
  default     = true
}

variable "default_root_object" {
  description = "The object that you want CloudFront to return (for example, index.html) when an end user requests the root URL."
  type        = string
  default     = "index.html"
}

variable "assets_dir_path" {
  description = "Directory path where assets would be stored. The same path would be cached by cloudfront."
  default = null
  type        = string
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
  validation {
    condition     = var.price_class == "PriceClass_All" || var.price_class == "PriceClass_200" || var.price_class == "PriceClass_100"
    error_message = "The value choosen is not in the list of ( PriceClass_All, PriceClass_200, PriceClass_100)."
  }
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

variable "origin_protocol_policy" {
  description = "Protocol that cloudfront to use when connecting to the origin. Supported values (http-only, https-only, or match-viewer)"
  type        = string
  default = "https-only"
}

##Cache Behavior Arguments###
#Regarding Methods: ##Regarding Methods Ref: https://jayendrapatil.com/aws-cloudfront/#:~:text=Allowed%20HTTP%20methods,and%20to%20get%20object%20headers.&text=CloudFront%20only%20caches%20responses%20to,and%2C%20optionally%2C%20OPTIONS%20requests.
variable "allowed_methods" {
  description = "Controls which HTTP methods CloudFront processes and forwards to your custom origin. for ex: 'DELETE', 'GET', 'HEAD', 'OPTIONS', 'PATCH', 'POST', 'PUT'"
  type        = list(any)
  default = ["GET", "HEAD", "OPTIONS"]
}

variable "cached_methods" {
  description = "Controls whether CloudFront caches the response to requests using the specified HTTP methods"
  type        = list(any)
  default = ["GET", "HEAD"]
}

variable "web_acl_id" {
  description = "If you're using AWS WAF to filter CloudFront requests, the Id of the AWS WAF web ACL that is associated with the distribution. The WAF Web ACL must exist in the WAF Global (CloudFront) region and the credentials configuring this argument must have waf:GetWebACL permissions assigned. If using WAFv2, provide the ARN of the web ACL."
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = null
}

variable "viewer_certificate" {
  description = "The SSL configuration for this distribution"
  type        = any
  default = {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1.2"
  }
}

variable "geo_restriction" {
  description = "The restriction configuration for this distribution (geo_restrictions)"
  type        = any
  default     = {}
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