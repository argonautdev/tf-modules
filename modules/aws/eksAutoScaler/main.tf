data "aws_eks_cluster" "cluster" {
  name = var.eks.id
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.eks.id
}

resource "helm_release" "cluster_autoscaler" {
  name       = "autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  version    = "9.10.4"

  values = [
    yamlencode({
      "awsRegion" : var.aws_region,
      "autoDiscovery" : {
        "clusterName" : data.aws_eks_cluster.cluster.name,
        "enabled" : true
      },
      "rbac" : {
        "create" : true,
        "serviceAccount" : {
          "name" : var.service_account_name,
          "annotations" : {
            "eks.amazonaws.com/role-arn" : var.role_arn
          }
        }
      }
  })]
}
