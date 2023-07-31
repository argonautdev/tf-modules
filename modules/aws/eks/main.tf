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
  # load_config_file       = false
}

data "aws_availability_zones" "available" {
}


##The intention is to take list of nodegroups and convert into the format node_groups expects i.e map()
##However, for_each loop only works inside a resource block and cannot do any operation inside node_groups variable
##Hence, creating a null resource and convert the variable from list to map and reference in node_groups variable

locals {
  #it should be {node_groups = {ng1 = {} ng2 = {}}
  #ref: https://stackoverflow.com/questions/62679195/terraform-looping-in-list-of-map How this local works
  ##either name or nameprefix 
  ng_list = { for ng in var.node_groups : ng.ng_name => ng }
  ng_list_replacements = { for k, v in local.ng_list : k => merge({
    capacity_type = v.spot ? "SPOT" : "ON_DEMAND"
    instance_types = [v.instance_type]
    name_prefix   = "${v.ng_name}-art-"
    version = var.cluster.version
    #subnets = var.vpc.private_secondary_subnets != null ? var.vpc.private_secondary_subnets : var.vpc.subnets
    subnets = length(data.aws_subnets.private_secondary.ids) > 0 ?  data.aws_subnets.private_secondary.ids : var.vpc.subnets
    k8s_labels = merge(v.k8s_labels, { Environment = var.env })
  }, v)}
}

##Read the secondary subnets
data "aws_subnets" "private_secondary" {
  filter {
    name   = "vpc-id"
    values = [var.vpc.id]
  }

  tags = {
    Type = "private_secondary"
  }
}

module "eks" {
  source = "github.com/argonautdev/terraform-eks?ref=v17.4.3"
  cluster_name             = var.cluster.name
  cluster_version          = var.cluster.version
  wait_for_cluster_timeout = 900
  subnets                  = var.vpc.subnets

  vpc_id = var.vpc.id
  
  node_groups = local.ng_list_replacements

  enable_irsa = true

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

  map_roles = concat(var.map_roles, [
    {
      rolearn  = aws_iam_role.eks_admin_role.arn
      username = "aws_iam_auth_admin"
      groups = [
        "system:masters",
        "system:bootstrappers",
        "system:nodes"
      ]
    }
  ])
  map_users    = var.map_users
  map_accounts = var.map_accounts
}

module "iam_assumable_role_admin" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "3.6.0"
  create_role                   = true
  role_name                     = "${data.aws_eks_cluster.cluster.name}-role"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.cluster_autoscaler.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.k8s_service_account_namespace}:${var.k8s_service_account_name}"]
}

resource "aws_iam_policy" "cluster_autoscaler" {
  name_prefix = "cluster-autoscaler"
  description = "EKS cluster-autoscaler policy for cluster ${module.eks.cluster_id}"
  policy      = data.aws_iam_policy_document.cluster_autoscaler.json
}

data "aws_iam_policy_document" "cluster_autoscaler" {
  statement {
    sid    = "clusterAutoscalerAll"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "eks:DescribeNodegroup",
      "ec2:DescribeLaunchTemplateVersions",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "clusterAutoscalerOwn"
    effect = "Allow"

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/kubernetes.io/cluster/${module.eks.cluster_id}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled"
      values   = ["true"]
    }
  }
}

data "aws_caller_identity" "account" {}

resource "aws_iam_role" "eks_admin_role" {
  name        = "${var.cluster.name}_eks_admin_role"
  description = "Kubernetes administrator role (for AWS IAM Group based Auth for Kubernetes)"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.account.account_id}:root"
        }
      },
    ]
  })
}

resource "aws_iam_group" "eks_admin_group" {
  name = "${var.cluster.name}_eks_admin_group"
}

resource "aws_iam_group_policy" "eks_admin_group_policy" {
  name  = "${var.cluster.name}_eks_admin_group_policy"
  group = aws_iam_group.eks_admin_group.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "sts:AssumeRole"
        Effect   = "Allow"
        Resource = aws_iam_role.eks_admin_role.arn
      },
    ]
  })
}

##Resource for adding EBSCSI Driver Policy to Node Role
resource "aws_iam_role_policy_attachment" "ebs_csi_policy_attach" {
  role       = module.eks.worker_iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}


