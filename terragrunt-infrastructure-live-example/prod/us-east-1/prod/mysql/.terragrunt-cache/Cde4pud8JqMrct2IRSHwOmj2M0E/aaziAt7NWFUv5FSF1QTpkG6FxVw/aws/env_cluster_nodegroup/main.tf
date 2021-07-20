provider "aws" {
  region = var.region
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

data "aws_availability_zones" "available" {
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.47"
  tags = var.default_tags

  name                 = var.vpc.name
  cidr                 = "172.16.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["172.16.1.0/24", "172.16.2.0/24", "172.16.3.0/24"]
  public_subnets       = ["172.16.4.0/24", "172.16.5.0/24", "172.16.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster.name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster.name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster.name
  cluster_version = "1.20"
  subnets         = module.vpc.private_subnets

  tags = var.default_tags

  vpc_id = module.vpc.vpc_id

  node_groups_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = var.node_group.disk_size
  }

  node_groups = {
    "${var.node_group.name}" = {
      name = var.node_group.name
      desired_capacity = var.node_group.desired_capacity
      max_capacity     = var.node_group.max_capacity
      min_capacity     = var.node_group.min_capacity

      instance_types = [var.node_group.instance_type]
      capacity_type  = var.node_group.spot ? "SPOT" : "ON_DEMAND"
      k8s_labels = {}
      additional_tags = var.default_tags
      node_group_name_prefix = ""
      # additional_tags = merge(var.default_tags, var.node_group_tags)
      # labels = var.node_group_labels
      taints = []
    }
  }

  # Create security group rules to allow communication between pods on workers and pods in managed node groups.
  # Set this to true if you have AWS-Managed node groups and Self-Managed worker groups.
  # See https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1089

  # worker_create_cluster_primary_security_group_rules = true

  # worker_groups_launch_template = [
  #   {
  #     name                 = "worker-group-1"
  #     instance_type        = "t3.small"
  #     asg_desired_capacity = 2
  #     public_ip            = true
  #   }
  # ]

  # map_roles    = var.map_roles
  map_users    = var.map_users
  map_accounts = var.map_accounts
}
