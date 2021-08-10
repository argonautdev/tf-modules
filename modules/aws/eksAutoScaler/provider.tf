terraform {
  required_version = ">= 0.15"

  required_providers {
    aws        = ">= 3.22.0"
    kubernetes = "~> 1.11"
    helm       = ">=2.2.0"
  }
}

provider "aws" {
  region  = var.aws_region
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
    # load_config_file       = false
    # exec {
    #   api_version = "client.authentication.k8s.io/v1alpha1"
    #   args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name]
    #   command     = "aws"
    # }
  }
}
