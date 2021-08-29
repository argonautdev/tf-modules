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

variable "create_database_subnet_group" {
  description = "Controls if database subnet group should be created (n.b. database_subnets must also be set)	"
  type        = bool
}

variable "create_database_subnet_route_table" {
  description = "Controls if separate route table for database should be created"
  type        = bool
}

variable "single_nat_gateway" {
  description = "To provision a single shared NAT Gateway across all of your private networks."
  type        = bool
}

variable "enable_dns_support" {
  description = "Whether or not the VPC has DNS support"
  type        = bool
}

variable "create_database_internet_gateway_route" {
  description = "Should be false if you do not want to auto-assign public IP on launch"
  type        = bool
}

variable "map_public_ip_on_launch" {
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

variable "database_subnet_cidr_blocks" {
  description = "Available cidr blocks for database subnets."
  type        = list(string)
}

variable "elasticache_subnet_cidr_blocks" {
  description = "Available cidr blocks for elasticache subnets."
  type        = list(string)
}
