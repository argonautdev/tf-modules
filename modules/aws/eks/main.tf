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
  load_config_file       = false
}

data "aws_availability_zones" "available" {
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "${var.cluster.name}-cluster"
  cluster_version = "1.21"
  wait_for_cluster_timeout = 900
  subnets         = var.vpc.private_subnets

  tags = var.default_tags

  vpc_id = var.vpc.vpc_id

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
      k8s_labels = {
        Environment = var.env
      }
      additional_tags = var.default_tags
      taints = [
        {
          key    = "dedicated"
          value  = "gpuGroup"
          effect = "NO_SCHEDULE"
        }
      ]
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

  #   map_roles    = var.map_roles
  map_users    = var.map_users
  map_accounts = var.map_accounts
}
