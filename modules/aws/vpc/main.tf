data "aws_availability_zones" "available" {}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.name
  cidr = "10.0.0.0/16"
  // cidr = var.cidr_block

  azs             = data.aws_availability_zones.available.names
  // private_subnets = slice(var.private_subnet_cidr_blocks, 0, var.private_subnet_count)
  // public_subnets  = slice(var.public_subnet_cidr_blocks, 0, var.public_subnet_count)
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  database_subnets = ["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]
  elasticache_subnets = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
  #   redshift_subnets    = ["20.10.41.0/24", "20.10.42.0/24", "20.10.43.0/24"]
  #   intra_subnets       = ["20.10.51.0/24", "20.10.52.0/24", "20.10.53.0/24"]
  create_database_subnet_group = true
  // create_elasticache_subnet_group = true
  // create_private_subnet_group = true


  manage_default_route_table = true
  default_route_table_tags   = { DefaultRouteTable = true }

  enable_dns_hostnames = var.enable_dns_hostnames

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway

  enable_vpn_gateway = var.enable_vpn_gateway

  // # Default security group - ingress/egress rules cleared to deny all
  // manage_default_security_group  = false
  // default_security_group_ingress = []
  // default_security_group_egress  = []

  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60
}