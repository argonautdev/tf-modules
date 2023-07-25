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
  default     = "10.0.0.0/16"
}

variable "enable_vpn_gateway" {
  description = "Enable a VPN gateway in your VPC."
  type        = bool
}

variable "secondary_cidr_blocks" {
  description = "List of secondary CIDR blocks to associate with the VPC to extend the IP Address pool"
  type        = list(string)
  default     = ["10.10.0.0/16"]
}

variable "secondary_cidr_subnet_blocks" {
  description = "List of secondary subnet CIDR blocks to associate with the VPC to extend the IP Address pool"
  type        = list(string)
  # default     = []
  default     = ["10.10.0.0/18", "10.10.64.0/18", "10.10.128.0/18" ]
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

variable "enable_flow_log" {
  description = "Whether or not to enable VPC Flow Logs"
  type        = bool
  default     = false
}

variable "create_flow_log_cloudwatch_log_group" {
  description = "Whether to create CloudWatch log group for VPC Flow Logs"
  type        = bool
  default     = false
}

variable "create_flow_log_cloudwatch_iam_role" {
  description = "Whether to create IAM role for VPC Flow Logs"
  type        = bool
  default     = false
}

variable "flow_log_traffic_type" {
  description = "The type of traffic to capture. Valid values: ACCEPT, REJECT, ALL."
  type        = string
  default     = "ALL"
}

variable "flow_log_max_aggregation_interval" {
  description = "The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record. Valid Values: `60` seconds or `600` seconds."
  type        = number
  default     = 600
}