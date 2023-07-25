data "aws_availability_zones" "available" {}

module "vpc" {
  source = "github.com/argonautdev/terraform-aws-vpc?ref=v5.1.1"

  name = var.name
  # cidr = "10.0.0.0/16"
  cidr = var.cidr_block

  azs             = data.aws_availability_zones.available.names
  // private_subnets = slice(var.private_subnet_cidr_blocks, 0, var.private_subnet_count)
  // public_subnets  = slice(var.public_subnet_cidr_blocks, 0, var.public_subnet_count)
  public_subnets  = var.public_subnet_cidr_blocks
  private_subnets = var.private_subnet_cidr_blocks
  private_secondary_subnets = var.secondary_cidr_subnet_blocks
  database_subnets = var.database_subnet_cidr_blocks
  elasticache_subnets = var.elasticache_subnet_cidr_blocks
  #   redshift_subnets    = ["20.10.41.0/24", "20.10.42.0/24", "20.10.43.0/24"]
  #   intra_subnets       = ["20.10.51.0/24", "20.10.52.0/24", "20.10.53.0/24"]
  create_database_subnet_group = true
  create_elasticache_subnet_group = true
  // create_private_subnet_group = true
  secondary_cidr_blocks    = var.secondary_cidr_blocks
  
  
  manage_default_route_table = true
  default_route_table_tags   = { DefaultRouteTable = true }

  enable_dns_hostnames = var.enable_dns_hostnames
  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway
  create_database_subnet_route_table     = var.create_database_subnet_route_table
  enable_dns_support         = var.enable_dns_support
  create_database_internet_gateway_route = var.create_database_internet_gateway_route
  map_public_ip_on_launch = var.map_public_ip_on_launch


  enable_vpn_gateway = var.enable_vpn_gateway

  // # Default security group - ingress/egress rules cleared to deny all
  // manage_default_security_group  = false
  // default_security_group_ingress = []
  // default_security_group_egress  = []

  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                      = var.enable_flow_log
  create_flow_log_cloudwatch_log_group = var.create_flow_log_cloudwatch_log_group
  create_flow_log_cloudwatch_iam_role  = var.create_flow_log_cloudwatch_iam_role
  flow_log_max_aggregation_interval    = var.flow_log_max_aggregation_interval
}