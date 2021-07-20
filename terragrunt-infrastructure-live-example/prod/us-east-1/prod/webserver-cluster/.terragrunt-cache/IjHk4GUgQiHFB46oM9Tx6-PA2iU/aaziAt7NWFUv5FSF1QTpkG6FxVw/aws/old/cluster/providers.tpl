terraform {
  required_version = ">= 0.15"
}

provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_eks_cluster_auth" "{{.Name}}" {
  name = "{{.Name}}"
}

provider "kubernetes" {
    host = aws_eks_cluster.{{.Name}}-{{.UID}}.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.{{.Name}}-{{.UID}}.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.{{.Name}}.token
}