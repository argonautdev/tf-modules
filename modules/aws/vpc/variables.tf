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

variable "enable_vpn_gateway" {
  description = "Enable a VPN gateway in your VPC."
  type        = bool
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC."
  type        = bool
}

variable "enable_nat_gateway" {
  description = "To provision NAT Gateways for each of your private networks."
  type        = bool
}

variable "single_nat_gateway" {
  description = "To provision a single shared NAT Gateway across all of your private networks."
  type        = bool
}

variable "public_subnet_count" {
  description = "Number of public subnets."
  type        = number
}

variable "private_subnet_count" {
  description = "Number of private subnets."
  type        = number
}

variable "public_subnet_cidr_blocks" {
  description = "Available cidr blocks for public subnets."
  type        = list(string)
}

variable "private_subnet_cidr_blocks" {
  description = "Available cidr blocks for private subnets."
  type        = list(string)
}