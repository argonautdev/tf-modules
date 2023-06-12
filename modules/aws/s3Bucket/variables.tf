variable "aws_region" {
  default     = "us-east-1"
  description = "s3 bucket region"
}

variable "visibility" {
  default     = "private"
  description = "switch bucket access to be public / private"
}

variable "name" {
  description = "name of bucket to be provisioned"
}

variable "force_destroy" {
  description = "force destroy s3 bucket with contents"
  default = true
}

variable "default_tags" {
  description = "Default Tags for s3"
  type        = map(string)
}

variable "control_object_ownership" {
  description = "Whether to manage S3 Bucket Ownership Controls on this bucket."
  type        = bool
  default     = true
}

variable "object_ownership" {
  description = "Object ownership. Valid values: BucketOwnerEnforced, BucketOwnerPreferred or ObjectWriter. 'BucketOwnerEnforced': ACLs are disabled, and the bucket owner automatically owns and has full control over every object in the bucket. 'BucketOwnerPreferred': Objects uploaded to the bucket change ownership to the bucket owner if the objects are uploaded with the bucket-owner-full-control canned ACL. 'ObjectWriter': The uploading account will own the object if the object is uploaded with the bucket-owner-full-control canned ACL."
  type        = string
  default     = "ObjectWriter"
}
