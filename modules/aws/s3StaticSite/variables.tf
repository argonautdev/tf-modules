variable "aws_region" {
  default = "us-east-1"
  description = "s3 bucket region"
}

variable "visibility" {
  default = "private"
  description = "Switch bucket access to be public / private"
}

variable "name" {
  description = "Bucket hosting the static site. The name should be exactly the same as the domain of the site to be served."
}

variable "log_bucket_name" {
  description = "Bucket to store logs"
}

variable "index_document" {
  description = "Index file path to serve"
}

variable "error_document" {
  description = "404 page path"
}

variable "website" {
  description = "website info to be filled in policy of s3"
  type = string
}

variable "default_tags" {
  description = "Default Tags"
  type        = map(string)
}
