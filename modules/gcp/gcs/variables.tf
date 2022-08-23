variable "project_id" {
  type        = string
  description = "The ID of the project where this VPC will be created"
}

variable "region" {
  type        = string
  description = "Region in which to deploy the resources"
}

variable "names" {
  description = "Bucket name suffixes."
  type        = list(string)
}
//Follow the below Docs for finding available location.
//Syntax to follow:
// For regions: <REGION_NAME>
// For Multi-region : "< MULTI_REGIONNAME>"
// For Dual regions: "<REGION1>+<REGION2>"
variable "location" {
  description = "Bucket location."
  type        = string
  default     = "EU"
}

##This seems a mandatory variables in main.tf 
############################################
#╷
#│ Error: Missing required argument
#│ 
#│   on modules/gcp/gcs/main.tf line 16, in module "gcs_bucket":
#│   16: module "gcs_bucket" {
#│ 
#│ The argument "prefix" is required, but no definition was found.
#################################################################

variable "prefix" {
  description = "Prefix used to generate the bucket name."
  type        = string
  default     = ""
}

variable "storage_class" {
  description = "Bucket storage class."
  type        = string
  default     = "STANDARD"
  
  validation {
    condition     = var.storage_class == "STANDARD" || var.storage_class == "NEARLINE" || var.storage_class == "COLDLINE" || var.storage_class == "ARCHIVE"  
    error_message = "The value choosen is not in the list of ( STANDARD, NEARLINE, COLDLINE or ARCHIVE )."
  }
}

variable "force_destroy" {
  description = "When deleting a bucket, this boolean option will delete all contained objects. If false, Terraform will fail to delete buckets which contain objects."
  type        = map(bool)
  default     = {}
}

variable "versioning" {
  description = "While set to true, versioning is fully enabled for this bucket."
  type        = map(bool)
  default     = {}
}

# variable "encryption" {
#   description = "A Cloud KMS key that will be used to encrypt objects inserted into this bucket"
#   type = object({
#     default_kms_key_name = string
#   })
#   default = null
# }

variable "encryption_key_names" {
  description = "A Cloud KMS key that will be used to encrypt objects inserted into this bucket"
  type        = map(string)
  default     = {}
}

variable "bucket_policy_only" {
  description = "Enables Bucket Policy Only access to a bucket. Disable ad-hoc ACLs on specified buckets."
  type        = map(bool)
  default     = {}
}

variable "labels" {
  description = "A set of key/value label pairs to assign to the bucket."
  type        = map(string)
  default     = {}
}

variable "default_labels" {
  description = "A set of default key/value label pairs to assign to the bucket."
  type        = map(string)
  default     = {}
}

variable "lifecycle_rules" {
  type = set(object({
    # Object with keys:
    # - type - The type of the action of this Lifecycle Rule. Supported values: Delete and SetStorageClass.
    # - storage_class - (Required if action type is SetStorageClass) The target Storage Class of objects affected by this Lifecycle Rule.
    action = map(string)

    # Object with keys:
    # - age - (Optional) Minimum age of an object in days to satisfy this condition.
    # - created_before - (Optional) Creation date of an object in RFC 3339 (e.g. 2017-06-13) to satisfy this condition.
    # - with_state - (Optional) Match to live and/or archived objects. Supported values include: "LIVE", "ARCHIVED", "ANY".
    # - matches_storage_class - (Optional) Comma delimited string for storage class of objects to satisfy this condition. Supported values include: MULTI_REGIONAL, REGIONAL, NEARLINE, COLDLINE, STANDARD, DURABLE_REDUCED_AVAILABILITY.
    # - num_newer_versions - (Optional) Relevant only for versioned objects. The number of newer versions of an object to satisfy this condition.
    # - custom_time_before - (Optional) A date in the RFC 3339 format YYYY-MM-DD. This condition is satisfied when the customTime metadata for the object is set to an earlier date than the date used in this lifecycle condition.
    # - days_since_custom_time - (Optional) The number of days from the Custom-Time metadata attribute after which this condition becomes true.
    # - days_since_noncurrent_time - (Optional) Relevant only for versioned objects. Number of days elapsed since the noncurrent timestamp of an object.
    # - noncurrent_time_before - (Optional) Relevant only for versioned objects. The date in RFC 3339 (e.g. 2017-06-13) when the object became nonconcurrent.
    condition = map(string)
  }))
  description = "List of lifecycle rules to configure. Format is the same as described in provider documentation https://www.terraform.io/docs/providers/google/r/storage_bucket.html#lifecycle_rule except condition.matches_storage_class should be a comma delimited string."
  default     = []
}


# variable "lifecycle_rules" {
#   description = "The bucket's Lifecycle Rules configuration."
#   type = list(object({
#     # Object with keys:
#     # - type - The type of the action of this Lifecycle Rule. Supported values: Delete and SetStorageClass.
#     # - storage_class - (Required if action type is SetStorageClass) The target Storage Class of objects affected by this Lifecycle Rule.
#     action = any

#     # Object with keys:
#     # - age - (Optional) Minimum age of an object in days to satisfy this condition.
#     # - created_before - (Optional) Creation date of an object in RFC 3339 (e.g. 2017-06-13) to satisfy this condition.
#     # - with_state - (Optional) Match to live and/or archived objects. Supported values include: "LIVE", "ARCHIVED", "ANY". ##This rule should be applied to non-current version objects ( ARCHIVED ) or versioned objects ( LIVE )
#     # - matches_storage_class - (Optional) Comma delimited string for storage class of objects to satisfy this condition. Supported values include: STANDARD, MULTI_REGIONAL, REGIONAL, NEARLINE, COLDLINE, ARCHIVE, DURABLE_REDUCED_AVAILABILITY.
#     # - num_newer_versions - (Optional) Relevant only for versioned objects. The number of newer versions of an object to satisfy this condition.
#     # - custom_time_before - (Optional) A date in the RFC 3339 format YYYY-MM-DD. This condition is satisfied when the customTime metadata for the object is set to an earlier date than the date used in this lifecycle condition.
#     # - days_since_custom_time - (Optional) The number of days from the Custom-Time metadata attribute after which this condition becomes true.
#     # - days_since_noncurrent_time - (Optional) Relevant only for versioned objects. Number of days elapsed since the noncurrent timestamp of an object.
#     # - noncurrent_time_before - (Optional) Relevant only for versioned objects. The date in RFC 3339 (e.g. 2017-06-13) when the object became nonconcurrent.
#     condition = any
#   }))
#   default = []
# }

variable "cors" {
  description = "Set of maps of mixed type attributes for CORS values. See appropriate attribute types here: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket#cors"
  type        = set(any)
  default     = []
}

variable "website" {
  type        = map(any)
  default     = {}
  description = "Map of website values. Supported attributes: main_page_suffix, not_found_page"
}

variable "retention_policy" {
  type        = any
  default     = {}
  description = "Map of retention policy values. Format is the same as described in provider documentation https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket#retention_policy"
}

variable "logging" {
  description = "Map of lowercase unprefixed name => bucket logging config object. Format is the same as described in provider documentation https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket#logging"
  type        = any
  default     = {}
}

##Bucket Permissions cloud be given by using following flags and permissions
# we need flags to allow member lists to contain dynamic elements

##Allow true if one should be granted with admin level access on objects
variable "set_admin_roles" {
  description = "Grant roles/storage.objectAdmin role to admins and bucket_admins."
  type        = bool
  default     = false
}

##Pass IAM list for each bucket, when tf apply happens it will add "roles/storage.objectAdmin". 
##It updates the bucket policy with IAM role on each user.
##Ref: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam#google_storage_bucket_iam_binding
variable "bucket_admins" {
  description = "Map of lowercase unprefixed name => comma-delimited IAM-style per-bucket admins."
  type        = map(string)
  default     = {}
}

##Allow true if one should be granted with create level access on objects
variable "set_creator_roles" {
  description = "Grant roles/storage.objectCreator role to creators and bucket_creators."
  type        = bool
  default     = false
}

##Pass IAM list for each bucket, when tf apply happens it will add "roles/storage.objectCreator". 
##It updates the bucket policy with IAM role on each user.
##Ref: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam#google_storage_bucket_iam_binding
variable "bucket_creators" {
  description = "Map of lowercase unprefixed name => comma-delimited IAM-style per-bucket creators."
  type        = map(string)
  default     = {}
}

##Allow true if one should be granted with read only access on objects
variable "set_viewer_roles" {
  description = "Grant roles/storage.objectViewer role to viewers and bucket_viewers."
  type        = bool
  default     = false
}

##Pass IAM list for each bucket, when tf apply happens it will add "roles/storage.objectViewer". 
##It updates the bucket policy with IAM role on each user.
##Ref: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam#google_storage_bucket_iam_binding
variable "bucket_viewers" {
  description = "Map of lowercase unprefixed name => comma-delimited IAM-style per-bucket viewers."
  type        = map(string)
  default     = {}
}

variable "set_hmac_key_admin_roles" {
  description = "Grant roles/storage.hmacKeyAdmin role to hmac_key_admins and bucket_hmac_key_admins."
  type        = bool
  default     = false
}

##Pass IAM list for each bucket, when tf apply happens it will add "roles/storage.hmacKeyAdmin". 
##It updates the bucket policy with IAM role on each user.
##Ref: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam#google_storage_bucket_iam_binding
variable "bucket_hmac_key_admins" {
  description = "Map of lowercase unprefixed name => comma-delimited IAM-style per-bucket HMAC Key admins."
  type        = map(string)
  default     = {}
}

##Allow true if one should be granted with admin access on objects and buckets
variable "set_storage_admin_roles" {
  description = "Grant roles/storage.admin role to storage_admins and bucket_storage_admins."
  type        = bool
  default     = false
}

##Pass IAM list for each bucket, when tf apply happens it will add "roles/storage.admin". 
##It updates the bucket policy with IAM role on each user.
##Ref: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam#google_storage_bucket_iam_binding
variable "bucket_storage_admins" {
  description = "Map of lowercase unprefixed name => comma-delimited IAM-style per-bucket storage admins."
  type        = map(string)
  default     = {}
}

##Type of access should be given at the bucket level
variable "bucket_access_level" {
  validation {
    condition     = var.bucket_access_level == "public" || var.bucket_access_level == "private"  
    error_message = "The value choosen is not in the list of ( STANDARD, NEARLINE, COLDLINE or ARCHIVE )."
  }
  default = "private"
  description = "Type of access should be given to the bucket. If it's public, anybody who is on the internet can read objects"
}


