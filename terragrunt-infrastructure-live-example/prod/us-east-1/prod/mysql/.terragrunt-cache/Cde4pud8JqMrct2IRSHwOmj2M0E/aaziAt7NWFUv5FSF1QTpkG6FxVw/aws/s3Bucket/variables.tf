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

variable "default_tags" {
  description = "Default Tags for s3"
  type        = map(string)
}
