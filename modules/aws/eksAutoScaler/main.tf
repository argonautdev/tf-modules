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
        "clusterName" : var.eks.id,
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
