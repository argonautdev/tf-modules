variable "default_tags" {
  description = "Default Tags for s3"
  type        = map(string)
}

variable "aws_region" {
  default     = "us-east-1"
  description = "s3 bucket region"
}

variable "name" {
  description = "VPC name"
}

variable "cidr_block" {
  description = "CIDR block for VPC"
  type        = string
}

variable "public_subnet_cidr_blocks" {
  description = "Available cidr blocks for public subnets."
  type        = list(string)
}

variable "private_subnet_cidr_blocks" {
  description = "Available cidr blocks for private subnets."
  type        = list(string)
}

variable "database_subnet_cidr_blocks" {
  description = "Available cidr blocks for database subnets."
  type        = list(string)
}

variable "elasticache_subnet_cidr_blocks" {
  description = "Available cidr blocks for elasticache subnets."
  type        = list(string)
}

variable "import_security_group_id" {
  description = "Default security group id, pass this value in case of vpc is imported"
  type        = string
}

variable "import_vpc_id" {
  description = "vpc id to be imported, pass this value in case of vpc is imported"
  type        = string
}